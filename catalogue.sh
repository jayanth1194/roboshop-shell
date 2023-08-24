#!/bin/bash 
ID=$(id -u)
DATE=$(date +%F)
LOG=/tmp/$ID_$DATE.log 
MONGOD_HOST="mongod.brainchange.com"




if [ $ID -ne 0 ]
then 
    echo " need sudo access"
    exit 1
fi 

VALIDATE(){
    if [ $? -ne 0 ]
    then 
        echo "$1 .......... SUCCESS"
    else 
        echo "$1 ................FAILURE "
    fi 
}

curl -sL https://rpm.nodesource.com/setup_lts.x | bash
VALIDATE " curl req" &>> $LOG
yum install nodejs -y
VALIDATE "node js"  &>> $LOG
useradd roboshop
VALIDATE "ADDED USER ROBOSHOP "  &>> $LOG
mkdir /app
VALIDATE " created app "  &>> $LOG
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
VALIDATE " downloaded source code " &>> $LOG
cd /app 
unzip /tmp/catalogue.zip
VALIDATE "ZIPPING FILE."
npm install 
VALIDATE " npm installed "
cp catalogue.txt /etc/systemd/system/catalogue.service
VALIDATE "copied file"
sed -i "s/<MONGODB-SERVER-IPADDRESS>/$MONGOD_HOST/"  /etc/systemd/system/catalogue.service
VALIDATE " changed mongodb server"
systemctl daemon-reload
VALIDATE "damon reload"
systemctl enable catalogue
VALIDATE " CATALOGUE START "
systemctl start catalogue
VALIDATE " CATALOGUE START " 
cp mongo-client /etc/yum.repos.d/mongo.repo
VALIDATE "copied file"
yum install mongodb-org-shell -y
VALIDATE "installed mongod"
mongo --host $MONGODB </app/schema/catalogue.js
VALIDATE " inserted data into mongod"