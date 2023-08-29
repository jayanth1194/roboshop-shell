#!/bin/bash 
USER=$(id -u)
DATE=$(date +%F)
LOG=/tmp/$0-$DATE.log 

INSTANCE_TYPE=
IMAGE_ID='ami-051f7e7f6c2f40dc1'
SECURITY_GRP='sg-07e78ffac793206c2'
DOMAIN_NAME=brainchange.online



NAME=("mongod" "redis" "mysql" "web" "cart")
for i in ${NAME[@]}
do 
    if [[ $i == "mongod" || $i == "mysql" ]]
    then 
        INSTANCE_TYPE="t3.medium"
    else 
        INSTANCE_TYPE="t2.micro"
    fi 
    echo "creating instance... :$i"
    IP_ADDRESS=$(
    aws ec2 run-instances --image-id $IMAGE_ID --count 1 --instance-type $INSTANCE_TYPE  --security-group-ids $SECURITY_GRP --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]"|jq -r '.Instances[0].PrivateIpAddress')
    echo " ip_address of $i...$IP_ADDRESS"
    aws route53 change-resource-record-sets --hosted-zone-id Z098285010FMU6PDV8O9P --change-batch '
    {
            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                            "Name": "'$i.$DOMAIN_NAME'",
                            "Type": "A",
                            "TTL": 300,
                            "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
                        }}]
    }
    '


done
