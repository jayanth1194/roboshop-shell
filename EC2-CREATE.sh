#!/bin/bash 
USER=$(id -u)
DATE=$(date +%F)
LOG=/tmp/$0-$DATE.log 

INSTANCE_TYPE=
IMAGE_ID='ami-051f7e7f6c2f40dc1'
SECURITY_GRP='sg-07e78ffac793206c2'




NAME=("mongod" "redis" "mysql" "web" "cart")
for i in ${NAME[@]}
do 
    if [[ $i == "mongod" || $i == "mysql" ]]
    then 
        INSTANCE_TYPE="t3.micro"
    else 
        INSTANCE_TYPE="t2.micro"
    fi 
    
    echo "creating instance... :$i"
    aws ec2 run-instances --image-id $IMAGE_ID --count 1 --instance-type $INSTANCE_TYPE  --security-group-ids $SECURITY_GRP --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]"

done
