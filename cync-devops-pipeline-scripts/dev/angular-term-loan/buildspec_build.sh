#!/bin/bash 
set -e
echo Build started on `date`
appPrefix="$APP_PREFIX"
#appVersion=$(cat version.txt )
timestamp=$(date -u '+%Y-%m-%d_%H-%M-%S_%Z')         
buildID=$(echo $CODEBUILD_BUILD_ID | awk -F':' '{print $2}')   
srcVer=$CODEBUILD_SOURCE_VERSION   
echo $CODEBUILD_SOURCE_VERSION 
echo "printing the branch name $GITHUB_BRANCH_NAME"
indx=$(echo $CODEBUILD_SOURCE_VERSION | grep -q ^arn ; echo $?)     
if [ "$indx" -eq 0 ]; then   
  srcVer=$CODEBUILD_RESOLVED_SOURCE_VERSION   
fi   
artifactversion=$(echo $appPrefix$GITHUB_BRANCH_NAME.$buildID.$srcVer.$timestamp)   
buildversion=$(echo $GITHUB_BRANCH_NAME.$buildID.$srcVer.$timestamp)  
artifactname=$(echo $artifactversion.tar.gz)
aws s3 cp s3://$DEVOPS_SCRIPTS_BUCKET/$SCRIPT_S3_PATH/appspec.yml .
aws s3 cp s3://$DEVOPS_SCRIPTS_BUCKET/$SCRIPT_S3_PATH/ansible_deploy.sh .   
echo $ANSIBLE_INVENTORY > env.txt  
cd $APP_HOME   
npm install   
npm run build
if [ ${ANSIBLE_INVENTORY} == "dev" ]
 then
     echo "Running sonar command"
     sonar-scanner -Dsonar.host.url=$SonarHost -Dsonar.login=$Sonartoken -Dsonar.login=$SonarUsername -Dsonar.password=$SonarPassword
fi
cd dist 
touch version-angular.html   
echo "$buildversion"> version-angular.html   
tar -zcvf $artifactname * 
aws s3 cp $artifactname s3://$ARTIFACT_BUCKET/$ARTIFACT_S3_FOLDER/

