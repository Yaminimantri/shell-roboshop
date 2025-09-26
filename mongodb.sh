#!/bin/bash


userid=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

logs_floder="var/log/shell-robosho"
script_name=$( echo $0 | cut -d "." -f1 )
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

for package in $@
do
    dnf list installed $package &>>$log_file
    if [ $? -ne 0 ]; then
        dnf install $package -y &>>$log_file
        validate $? "$package"
    else
        echo -e "$package already exist..$Y skipping $N"
    fi
done

cp mongodb.repo vim /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongo repo"

dnf install mongodb-org -y &>>$log_file
VALIDATE $? "Installing MongoDB"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enable MongoDB"

systemctl start mongod 
VALIDATE $? "Start MongoDB"

