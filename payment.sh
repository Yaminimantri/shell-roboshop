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
MYSQL_HOST=mysql.yaminiaws.fun


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


dnf install python3 gcc python3-devel -y &>>$log_file


id roboshop &>>$log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log_file
    validate $? "Creating system user"
else
    echo -e "User already exist ... $Y SKIPPING $N"
fi

mkdir -p /app
validate $? "Creating app directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$log_file
validate $? "Downloading payment application"

cd /app 
validate $? "Changing to app directory"

rm -rf /app/*
validate $? "Removing existing code"

unzip /tmp/payment.zip &>>$log_file
validate $? "unzip payment"

pip3 install -r requirements.txt &>>$log_file

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
systemctl daemon-reload
systemctl enable payment  &>>$log_file

systemctl restart payment