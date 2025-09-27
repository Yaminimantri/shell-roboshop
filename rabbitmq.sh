#!/bin/bash

userid=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

logs_floder="var/log/shell-robosho"
script_name=$( echo $0 | cut -d "." -f1 )
log_file="$log_floder/$script_name.log"
START_TIME=$(date +%s)
mkdir -p $logs_floder
SCRIPT_DIR=$PWD
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

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$log_file
validate $? "Adding RabbitMQ repo"
dnf install rabbitmq-server -y &>>$log_file
validate $? "Installing RabbitMQ Server"
systemctl enable rabbitmq-server &>>$log_file
validate $? "Enabling RabbitMQ Server"
systemctl start rabbitmq-server &>>$log_file
validate $? "Starting RabbitMQ"
rabbitmqctl add_user roboshop roboshop123 &>>$log_file
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$log_file
validate $? "Setting up permissions"


END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"