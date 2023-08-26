#!/bin/bash 


USER=$(id -u)
DATE=$(date +%F)

LOG=/tmp/$0-$DATE.log 


VALIDATE(){
    if [ $? -ne 0 ]
    then 
        echo "$1 ..............FAILURE"
        exit 1

    else 
        echo "$1.....................SUCCESS"
    fi 

}
VALIDATE_REDIS(){
    yum list installed redis 
    if [ $? -eq 0 ]
    then 
        echo " redis is already installed"
        CHECK_STATUS

        exit 1
    else 
        installredis
    fi
}

installredis(){
    yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>$LOG
    VALIDATE "repo downloaded "
    yum module enable redis:remi-6.2 -y &>>$LOG
    VALIDATE " enabled redis 6.2"
    yum install redis -y  &>>$LOG
    VALIDATE "redis installed"
    CHECK_STATUS
}




CHECK_STATUS(){

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf /etc/redis/redis.conf 
VALIDATE " changed to all networks"

systemctl enable redis &>>$LOG
VALIDATE " redis enabled"
systemctl start redis &>>$LOG
VALIDATE " redis started"

}


if [ $USER -ne 0 ]
then 
    echo " need root access "
    exit 1 
fi 
VALIDATE_REDIS