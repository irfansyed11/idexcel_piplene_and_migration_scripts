#!/bin/bash
apt-get update -y   
npm install -g @angular/cli@7.3.3
if [ ${ANSIBLE_INVENTORY} == "dev" ]
 then
     echo "Installing sonarscanner"
     npm install -g sonarqube-scanner 
fi
