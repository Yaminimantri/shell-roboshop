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

dnf module disable nodejs -y &>>$log_file
dnf module enable nodejs:20 -y  &>>$log_file
validate $? "Enabling NodeJS 20"
dnf install nodejs -y &>>$log_file
validate $? "Installing NodeJS"

id roboshop &>>$log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system cart" roboshop &>>$log_file
    validate $? "Creating system cart"
else
    echo -e "User already exist ... $Y SKIPPING $N"
fi

mkdir -p /app
validate $? "Creating app directory"

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$log_file
validate $? "Downloading cart application"

cd /app 
validate $? "Changing to app directory"

rm -rf /app/*
validate $? "Removing existing code"

unzip /tmp/cart.zip &>>$log_file
validate $? "unzip cart"

npm install &>>$log_file
validate $? "Install dependencies"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
validate $? "Copy systemctl service"

systemctl daemon-reload
systemctl enable cart &>>$log_file
validate $? "Enable cart"

systemctl restart cart
validate $? "Restarted cart"
