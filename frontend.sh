#!/bin/bash

userid=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

logs_floder="var/log/shell-robosho"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.yaminiaws.fun
log_file="$log_floder/$script_name.log"

mkdir -p $logs_floder
echo "script started executed at: $(date)" | tee -a $log_file 

if [ $userid -ne 0 ]; then
    echo "ERROR: please run this script with root privelege"
    exit 1
fi

validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$2...$R failure $N" | tee -a $log_file
        exit 1
    else
        echo -e "$2...$G succuss $N" | tee -a $log_file 
    fi
}

dnf module disable nginx -y &>>$log_file 
dnf module enable nginx:1.24 -y &>>$log_file 
dnf install nginx -y &>>$log_file 
validate $? "Installing Nginx"

systemctl enable nginx  &>>$log_file 
systemctl start nginx 
validate $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* 
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$log_file 
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$log_file 
validate $? "Downloading frontend"

rm -rf /etc/nginx/nginx.conf
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
validate $? "Copying nginx.conf"

systemctl restart nginx 
validate $? "Restarting Nginx"