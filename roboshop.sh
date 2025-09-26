

ami_id="ami-09c813fb71547fc4f"
sg_id="sg-0e9e29a7d8854c36b"

for instance in $@
do
    Instance_Id=$(aws ec2 run-instances --image-id $ami_id --instance-type t3.micro --security-group-ids $sg_id --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)
    if [ $instace != "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids $Instance_Id --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
    else
        IP=$(aws ec2 describe-instances --instance-ids $Instance_Id --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    fi 
    echo "$instance : $IP"
done

