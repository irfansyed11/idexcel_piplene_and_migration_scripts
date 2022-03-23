#!/bin/bash
set -e
echo Build completed on `date`
appPrefix="cync-cash-app-" 
timestamp=$(date -u '+%Y-%m-%d_%H-%M-%S_%Z')      
 
#- buildID=$(echo $CODEBUILD_BUILD_ID | awk -F':' '{print $2}') 
srcVer=$CODEBUILD_SOURCE_VERSION 
echo $CODEBUILD_SOURCE_VERSION
echo "printing the branch name $GITHUB_BRANCH_NAME"
indx=$(echo $CODEBUILD_SOURCE_VERSION | grep -q ^arn ; echo $?) 
if [ "$indx" -eq 0 ]; then 
  srcVer=$CODEBUILD_RESOLVED_SOURCE_VERSION 
fi  
artifactversion=$(echo $appPrefix$GITHUB_BRANCH_NAME.$srcVer.$timestamp) 
touch version.html 
echo "$artifactversion" >> version.html
ls
aws s3 cp s3://$CONFIG_BUCKET/cashapp-database.yml config/database.yml
aws s3 cp s3://$CONFIG_BUCKET/cashapp_ror_admin_db.yml config/admin_db.yml
aws s3 cp s3://$CONFIG_BUCKET/rds-combined-ca-bundle.pem rds-combined-ca-bundle.pem
ls config/*
apt install apt-transport-https ca-certificates curl software-properties-common gnupg -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" | tee /etc/apt/sources.list.d/docker.list
apt update -y
curl -O https://download.docker.com/linux/debian/dists/buster/pool/stable/amd64/containerd.io_1.4.3-1_amd64.deb
apt install ./containerd.io_1.4.3-1_amd64.deb
apt install docker-ce -y
#pip install docker-compose
service docker start
bundle install
bundle package --all
brakeman --no-exit-on-warn --no-exit-on-error -o cashapp_ror_brakeman_report_$timestamp.html
#aws s3 cp cashapp_ror_brakeman_report_$timestamp.html s3://$STATIC_CODE_REPORTS_BUCKET/cync/cash-app-reports/ --sse
#- docker-compose build
#- docker-compose up
$(aws ecr get-login --no-include-email --region $AWS_DEFAULT_REGION) 
echo Building the Docker image...   
docker build -t $IMAGE_REPO_NAME:$IMAGE_TAG . 
docker tag $IMAGE_REPO_NAME:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG 
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG 
      #- #echo Sync code analysis reports to S3 
      #- #aws s3 sync target/reports/ s3://$STATIC_CODE_REPORTS_BUCKET/term-loan-service/ 
      #- aws s3api put-object --bucket dev-finance-microservice --key artifacts/financial-analysis-0.0.1-SNAPSHOT.jar --body /target/financial-analysis-0.0.1-SNAPSHOT.jar --tagging 'VersionNo=1&DeploymentIdentifier=CURRENT' 
#artifacts: 
 # files: 
    #- version.html 
  #discard-paths: yes
