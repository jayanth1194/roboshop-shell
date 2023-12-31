#!/bin/bash 
ID=$(id -u)
DATE=$(date +%F)
NAME=$0
LOG=/tmp/$0_$DATE.log 
MONGOD_HOST="mongodb.chamarthiaparna.online"




if [ $ID -ne 0 ]
then 
    echo " need sudo access"
    exit 1
fi 

VALIDATE(){
    if [ $? -ne 0 ]
    then 
        echo "$1 .......... FAILURE"
        exit 1 
    else 
        echo "$1 ................success "
    fi 
}


check_node(){
    yum list install nodejs
    if  [ $? -eq 0 ]
    then 
        echo " node already installed "
    else 
        install_node
    fi 
}

install_node(){
echo "curl -sL https://rpm.nodesource.com/setup_lts.x | bash"  &>> $LOG
VALIDATE " curl req"  &>> $LOG
yum install nodejs -y &>> $LOG
VALIDATE "node js"  &>> $LOG
}


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

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
VALIDATE " downloaded source code " &>> $LOG
cd /app 
 
unzip /tmp/catalogue.zip
VALIDATE "ZIPPING FILE."
cd /app
npm install &>> $LOG
VALIDATE " npm installed "
cp /home/centos/roboshop-shell/catalogue.txt /etc/systemd/system/catalogue.service
VALIDATE "copied file" 
sed -i "s/<MONGODB-SERVER-IPADDRESS>/$MONGOD_HOST/g"  /etc/systemd/system/catalogue.service
VALIDATE " changed mongodb server"
systemctl daemon-reload &>> $LOG
VALIDATE "damon reload" &>> $LOG
systemctl enable catalogue &>> $LOG
VALIDATE " CATALOGUE enable " &>> $LOG
systemctl start catalogue &>> $LOG
VALIDATE " CATALOGUE START " &>> $LOG
cp /home/centos/roboshop-shell/mongo-client /etc/yum.repos.d/mongo.repo
VALIDATE "copied file"
yum install mongodb-org-shell -y &>> $LOG
VALIDATE "installed mongod" &>> $LOG
mongo --host $MONG0D_HOST </app/schema/catalogue.js &>> $LOG
VALIDATE " inserted data into mongod" &>> $LOG