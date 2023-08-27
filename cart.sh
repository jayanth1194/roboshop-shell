#!/bin/bash

USER=$(id -u)
DATE=$(date +%F)
DIR=/app
LOG=/tmp/$0-$DATE.log 


VALIDATE(){
    if [ $? -ne 0 ]
    then 
        echo "$1 ..............FAILURE"
        exit 1
    else 
        echo "$1.............SUCCESS"
    fi 
}
check_node(){
    yum list installed node 
    if [ $? -ne 0 ]
    then 
        echo " node is installed already..."
    else 
        install_node
}
install_node(){
    curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>$LOG
    VALIDATE "Repo downloaded ......"
    yum install nodejs -y 
    VALIDATE " installed nodejs ...."
}



if [ $USER -ne 0 ]
then 
    echo " need root access ..."
    exit 1 
fi 

check_node

id roboshop
if [ $? -ne 0  ]
then 
    echo " roboshop not exists... "
    useradd roboshop 
    VALIDATE " created roboshop user"
    
else 
    echo "roboshop user exists..."
fi 

if [ -d $DIR ]
then 
    echo "app dir exists"
else 
    mkdir /app
    VALIDATE "  create app dir....  "
    
fi 
chmod 777 /tmp 
VALIDATE "permission changed tmp...."

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>>$LOG
VALIDATE " Downloaded aritifact......."
cd /app
unzip /tmp/cart.zip
VALIDATE "unzipped the folder ......."
cd /app 
npm install &>>$LOG
cp /home/centos/roboshop-shell/cart.service  /etc/systemd/system/cart.service
VALIDATE "copied the cart service ....."

systemctl daemon-reload &>>$LOG
VALIDATE " daemon reload ..."
systemctl enable cart &>>$LOG
VALIDATE "enbaled cart ..."
systemctl start cart &>>$LOG
VALIDATE " service start cart ......"




