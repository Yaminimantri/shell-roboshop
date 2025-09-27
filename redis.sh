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

dnf module disable redis -y &>>$log_file 
validate $? "Disabling Default Redis"
dnf module enable redis:7 -y &>>$log_file 
validate $? "Enabling Redis 7"
dnf install redis -y  &>>$log_file 
validate $? "Installing Redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
validate $? "Allowing Remote connections to Redis"

systemctl enable redis &>>$log_file 
validate $? "Enabling Redis"
systemctl start redis &>>$log_file 
validate $? "Starting Redis"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"