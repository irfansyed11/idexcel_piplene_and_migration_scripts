#!/bin/bash
#set -e
apt-get update -y   
apt-get -y install software-properties-common 
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list   
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list   
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886   
apt-get -y install curl   
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -  
apt-get update -y   
echo "Installing dependencies - @Aangular/cli"   
apt-get -y install nodejs   
npm install -g @angular/cli@7.1.4 
