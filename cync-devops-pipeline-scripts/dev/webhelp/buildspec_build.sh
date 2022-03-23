#!/bin/bash 
echo Build started on `date`
echo `pwd`
appPrefix=$(echo $APP_PREFIX)_
timestamp=$(date -u '+%Y-%m-%d_%H-%M-%S_%Z')
buildID=$(echo $CODEBUILD_BUILD_ID | awk -F':' '{print $2}')
srcVer=$CODEBUILD_SOURCE_VERSION
echo $srcVer 
echo $CODEBUILD_RESOLVED_SOURCE_VERSION
echo "printing the branch name $GITHUB_BRANCH_NAME" 
indx=$(echo $CODEBUILD_SOURCE_VERSION | grep -q ^arn ; echo $?)
if [ "$indx" -eq 0 ]; then
  srcVer=$CODEBUILD_RESOLVED_SOURCE_VERSION
fi
artifactversion=$(echo $appPrefix$GITHUB_BRANCH_NAME.$buildID.$srcVer.$timestamp)
buildversion=$(echo $GITHUB_BRANCH_NAME.$buildID.$srcVer.$timestamp)
echo $ANSIBLE_INVENTORY > env.txt
aws s3 cp s3://$DEVOPS_SCRIPTS_BUCKET/$SCRIPT_S3_PATH/appspec.yml .
aws s3 cp s3://$DEVOPS_SCRIPTS_BUCKET/$SCRIPT_S3_PATH/ansible_deploy.sh .
touch version.html
echo "$buildversion"> version.html
cat version.html
cp version.html ./content/
content_artifactname=$(echo content_$artifactversion.tar.gz)
mapping_artifactname=$(echo mapping_$artifactversion.tar.gz)
envName=$(echo EnvName=$CYNC_ENV)
tar -zcvf $content_artifactname content
tar -zcvf $mapping_artifactname mapping
aws s3 cp $content_artifactname s3://$ARTIFACT_BUCKET/$ARTIFACT_S3_FOLDER/ --sse
aws s3 cp $mapping_artifactname s3://$ARTIFACT_BUCKET/$ARTIFACT_S3_FOLDER/ --sse
