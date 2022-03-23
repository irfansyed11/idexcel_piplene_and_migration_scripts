#!/bin/bash
set -e
echo Build started on `date`    
APP_PREFIX_Archive="$APP_PREFIX_Archive"
APP_PREFIX_Clear="$APP_PREFIX_Clear"
APP_PREFIX_Fetch="$APP_PREFIX_Fetch"
APP_PREFIX_Save="$APP_PREFIX_Save"
APP_PREFIX_Send="$APP_PREFIX_Send"
APP_PREFIX_UpdateStatus="$APP_PREFIX_UpdateStatus"
timestamp=$(date -u '+%Y-%m-%d_%H-%M-%S-%Z')  
buildID=$(echo $CODEBUILD_BUILD_ID | awk -F':' '{print $2}')  
srcVer=$CODEBUILD_SOURCE_VERSION    
echo $CODEBUILD_SOURCE_VERSION  
indx=$(echo $CODEBUILD_SOURCE_VERSION | grep -q ^arn ; echo $?)
if [ "$indx" -eq 0 ]; then    
  srcVer=$CODEBUILD_RESOLVED_SOURCE_VERSION  
fi    
artifactversion_Archive=$(echo $APP_PREFIX_Archive$appVersion.$buildID.$srcVer.$timestamp)
artifactversion_Clear=$(echo $APP_PREFIX_Clear$appVersion.$buildID.$srcVer.$timestamp)
artifactversion_Fetch=$(echo $APP_PREFIX_Fetch$appVersion.$buildID.$srcVer.$timestamp)
artifactversion_Save=$(echo $APP_PREFIX_Save$appVersion.$buildID.$srcVer.$timestamp)
artifactversion_Send=$(echo $APP_PREFIX_Send$appVersion.$buildID.$srcVer.$timestamp)
artifactversion_UpdateStatus=$(echo $APP_PREFIX_UpdateStatus$appVersion.$buildID.$srcVer.$timestamp)
artifactname_Archive=$(echo $artifactversion_Archive.zip)
artifactname_Clear=$(echo $artifactversion_Clear.zip)
artifactname_Fetch=$(echo $artifactversion_Fetch.zip)
artifactname_Save=$(echo $artifactversion_Save.zip)
artifactname_Send=$(echo $artifactversion_Send.zip)
artifactname_UpdateStatus=$(echo $artifactversion_UpdateStatus.Zip)

echo 'pwd'
cd NotificationService/ArchiveNotification
echo 'CODEBUILD_SOURCE_VERSION::::'  $CODEBUILD_SOURCE_VERSION
echo 'CODEBUILD_RESOLVED_SOURCE_VERSION :::::' $CODEBUILD_RESOLVED_SOURCE_VERSION
echo 'Artifact name :::::'  $artifactname_Archive
echo Copy artifact file to S3
zip -r $artifactname_Archive *
aws s3 cp $artifactname_Archive s3://$ARTIFACT_BUCKET/$ARTIFACT_S3_FOLDER/
aws lambda update-function-code --function-name $ArchiveLambdafunctionname --zip-file fileb://$artifactname_Archive
cd ../..
cd NotificationService/ClearNotification
echo 'CODEBUILD_SOURCE_VERSION::::'  $CODEBUILD_SOURCE_VERSION
echo 'CODEBUILD_RESOLVED_SOURCE_VERSION :::::' $CODEBUILD_RESOLVED_SOURCE_VERSION
echo 'Artifact name :::::'  $artifactname_Clear
echo Copy artifact file to S3
zip -r $artifactname_Clear *
aws s3 cp $artifactname_Clear s3://$ARTIFACT_BUCKET/$ARTIFACT_S3_FOLDER/
aws lambda update-function-code --function-name $ClearLambdafunctionname --zip-file fileb://$artifactname_Clear
cd ../..
cd NotificationService/FetchNotification
echo 'CODEBUILD_SOURCE_VERSION::::'  $CODEBUILD_SOURCE_VERSION
echo 'CODEBUILD_RESOLVED_SOURCE_VERSION :::::' $CODEBUILD_RESOLVED_SOURCE_VERSION
echo 'Artifact name :::::'  $artifactname_Fetch
echo Copy artifact file to S3
zip -r $artifactname_Fetch *
aws s3 cp $artifactname_Fetch s3://$ARTIFACT_BUCKET/$ARTIFACT_S3_FOLDER/
aws lambda update-function-code --function-name $FetchLambdafunctionname  --zip-file fileb://$artifactname_Fetch
cd ../..
cd NotificationService/SaveNotification
echo 'CODEBUILD_SOURCE_VERSION::::'  $CODEBUILD_SOURCE_VERSION
echo 'CODEBUILD_RESOLVED_SOURCE_VERSION :::::' $CODEBUILD_RESOLVED_SOURCE_VERSION
echo 'Artifact name :::::'  $artifactname_Save
echo Copy artifact file to S3
zip -r $artifactname_Save *
aws s3 cp $artifactname_Save s3://$ARTIFACT_BUCKET/$ARTIFACT_S3_FOLDER/
aws lambda update-function-code --function-name $SaveLambdafunctionname  --zip-file fileb://$artifactname_Save #Dev-SaveNotifications
cd ../..
cd NotificationService/SendNotification
echo 'CODEBUILD_SOURCE_VERSION::::'  $CODEBUILD_SOURCE_VERSION
echo 'CODEBUILD_RESOLVED_SOURCE_VERSION :::::' $CODEBUILD_RESOLVED_SOURCE_VERSION
echo 'Artifact name :::::'  $artifactname_Send
echo Copy artifact file to S3
zip -r $artifactname_Send *
aws s3 cp $artifactname_Send s3://$ARTIFACT_BUCKET/$ARTIFACT_S3_FOLDER/
aws lambda update-function-code --function-name $SendLambdafunctionname  --zip-file fileb://$artifactname_Send
cd ../..
cd NotificationService/UpdateStatusofViewNotification
echo 'CODEBUILD_SOURCE_VERSION::::'  $CODEBUILD_SOURCE_VERSION
echo 'CODEBUILD_RESOLVED_SOURCE_VERSION :::::' $CODEBUILD_RESOLVED_SOURCE_VERSION
echo 'Artifact name :::::'  $artifactname_UpdateStatus
echo Copy artifact file to S3
zip -r $artifactname_UpdateStatus *
aws s3 cp $artifactname_UpdateStatus s3://$ARTIFACT_BUCKET/$ARTIFACT_S3_FOLDER/
aws lambda update-function-code --function-name $UpdateLambdafunctionname --zip-file fileb://$artifactname_UpdateStatus

