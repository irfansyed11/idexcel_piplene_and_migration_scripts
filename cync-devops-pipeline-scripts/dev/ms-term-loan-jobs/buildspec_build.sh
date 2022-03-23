#!/bin/bash 
set -e
echo Build completed on `date`
echo Sync files to S3
appPrefix="cync-term-loan-jobs-0.0.1-SNAPSHOT_"
timestamp=$(date -u '+%Y-%m-%d_%H-%M-%S_%Z')     
#- buildID=$(echo $CODEBUILD_BUILD_ID | awk -F':' '{print $2}')
srcVer=$CODEBUILD_SOURCE_VERSION
echo $CODEBUILD_SOURCE_VERSION
indx=$(echo $CODEBUILD_SOURCE_VERSION | grep -q ^arn ; echo $?)
if [ "$indx" -eq 0 ]; then
  srcVer=$CODEBUILD_RESOLVED_SOURCE_VERSION
fi
artifactversion=$(echo $appPrefix$srcVer.$timestamp.jar)
touch version.txt
echo "$artifactversion" >> version.txt
aws s3 cp version.txt s3://$ARTIFACT_BUCKET/version.txt
aws s3 cp target/cync-term-loan-jobs-0.0.1-SNAPSHOT.jar s3://$ARTIFACT_BUCKET/$artifactversion
$(aws ecr get-login --no-include-email --region $AWS_DEFAULT_REGION)
echo Building the Docker image...  
docker build -t $IMAGE_REPO_NAME:$artifactversion --build-arg RDSCertificateBucket=$RDS_CERTIFICATE_BUCKET .
docker tag $IMAGE_REPO_NAME:$artifactversion $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$artifactversion
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$artifactversion
MANIFEST=$(aws ecr batch-get-image --region $AWS_DEFAULT_REGION --registry-id $AWS_ACCOUNT_ID --repository-name $IMAGE_REPO_NAME --image-ids imageTag=$IMAGE_TAG --query 'images[].imageManifest' --output text)
aws ecr batch-delete-image --region $AWS_DEFAULT_REGION --registry-id $AWS_ACCOUNT_ID --repository-name $IMAGE_REPO_NAME --image-ids imageTag=$IMAGE_TAG
MANIFEST=$(aws ecr batch-get-image --region $AWS_DEFAULT_REGION --registry-id $AWS_ACCOUNT_ID --repository-name $IMAGE_REPO_NAME --image-ids imageTag=$artifactversion --query 'images[].imageManifest' --output text)
aws ecr put-image --region $AWS_DEFAULT_REGION --registry-id $AWS_ACCOUNT_ID --repository-name $IMAGE_REPO_NAME --image-tag $IMAGE_TAG --image-manifest "$MANIFEST"
#- docker build -t $IMAGE_REPO_NAME:$IMAGE_TAG --build-arg RDSCertificateBucket=$RDS_CERTIFICATE_BUCKET .
#- docker tag $IMAGE_REPO_NAME:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
#- docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
#- #echo Sync code analysis reports to S3
#- #aws s3 sync target/reports/ s3://$STATIC_CODE_REPORTS_BUCKET/term-loan-service/
#- aws s3api put-object --bucket dev-finance-microservice --key artifacts/financial-analysis-0.0.1-SNAPSHOT.jar --body /target/financial-analysis-0.0.1-SNAPSHOT.jar --tagging 'VersionNo=1&DeploymentIdentifier=CURRENT'
