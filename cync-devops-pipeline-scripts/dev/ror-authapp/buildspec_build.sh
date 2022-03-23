#!/bin/bash 
echo Build started on `date`
echo `pwd`
appPrefix=$(echo $APP_PREFIX)_
appVersion=$(cat version.txt )
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
mv version.html $APP_HOME/public/
artifactname=$(echo $artifactversion.tar.gz)
envName=$(echo EnvName=$CYNC_ENV)
tar -zcvf $artifactname *
aws s3 cp $artifactname s3://$ARTIFACT_S3_BUCKET/$ARTIFACT_S3_FOLDER/ --sse
aws s3api put-object --bucket $ARTIFACT_S3_BUCKET --key $ARTIFACT_S3_FOLDER/$artifactname --body $artifactname
