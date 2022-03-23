#!/bin/bash
#echo Pre-Build Installations started on `date`
#pip install --upgrade pip
#pip install pipenv --user
#pip install awscli aws-sam-cli
apt install zip 
echo "#####NPM INSTALLATION ###########"
cd NotificationService/ArchiveNotification
npm install
cd ../..
cd NotificationService/ClearNotification
npm install
cd ../..
cd NotificationService/FetchNotification
npm install
cd ../..
cd NotificationService/SaveNotification
npm install
cd ../..
cd NotificationService/SendNotification
npm install
cd ../..
cd NotificationService/UpdateStatusofViewNotification
npm install
echo Pre-Build Installations Finished on `date`
