#!/bin/bash 
USER=$(id -u)
DATE=$(date +%F)
LOG=/tmp/$0-$DATE.log 


NAME=("mongo","redis","mysql","web","cart")
for i in ${NAME[@]}
do 
    echo "$NAME :$i"
done
