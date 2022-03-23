#!/bin/bash
set -ex
#echo "Starting pushing the jenkin backup of $1 kinf of backup"
{
aws sns publish --topic-arn arn:aws:sns:ap-south-1:286605220849:Migration-Test-Jenkins-Backup-Alert --subject "pushing jenkin backup to S3 of $1 kinf of backup - Started" --message "pushing jenkin backup to S3 of $1 kinf of backup - Started" --region ap-south-1
latest_backup_folder=$(ls -td -- $1*/ | head -n 1| cut -d'/' -f1)
echo $latest_backup_folder
if [[ $latest_backup_folder != "" ]];then
zip_file_name="$latest_backup_folder".zip
zip -r $zip_file_name $latest_backup_folder/
aws s3 cp $zip_file_name s3://jenkins-jobs-plugins-backup
#echo "Ended pushing the jenkin backup of $1 kind of backup into s3 done"
rm -f $zip_file_name
aws sns publish --topic-arn arn:aws:sns:ap-south-1:286605220849:Migration-Test-Jenkins-Backup-Alert --subject "pushing jenkin backup to S3 of $1 kinf of backup - Success" --message "pushing jenkin backup to S3 of $1 kinf of backup - Success" --region ap-south-1
else
  email_msg="Folder not available to push s3 bucket $1  kind of backup"
  echoo
fi
} || {
aws sns publish --topic-arn arn:aws:sns:ap-south-1:286605220849:Migration-Test-Jenkins-Backup-Alert --subject "pushing jenkin backup to S3 of $1 kinf of backup - Failed" --message "Reason for failure: $email_msg" --region ap-south-1

}