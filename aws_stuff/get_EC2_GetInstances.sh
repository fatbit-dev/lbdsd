#!/bin/bash

error() {
  echo -e "\e[31m $@ \e[0m"
}

usage() {
	error ">>> Error: ${0} needs one argument:"
	echo -e ">>>   - AWS EC2 Instance ID"
	echo -e ">>> Example:"
	echo -e ">>> \t${0} i-0199e5bf7623c53f4"
}

aws ec2 describe-instances \
    --region eu-west-1 \
    --filters \
        Name=instance-type,Values=t2.micro,t3.micro \
        Name=tag-key,Values=Project \
        Name=tag-value,Values=LBDSD \
        Name=tag-key,Values=CanBeStopped \
        Name=tag-value,Values=true \
    | grep "InstanceId" | head -n 1

# aws ec2 describe-instances \
#     --query 'Reservations[].Instances[].{Name: Tags[?Key==`Name`].Value | [0], Role: Tags[?Key==`Billing by Role`].Value | [0]}' \
#     --output text

# aws ec2 describe-instances \
#     --region eu-west-1 \
#     --filters file://filter.json \
#     | grep "InstanceId" | head -n 1

# Contents of filter.json file:
#
# [
#     {
#         "Name": "instance-type",
#         "Values": ["t2.micro", "t3.micro"]
#     },
#     {
#         "Name": "availability-zone",
#         "Values": ["eu-west-1"]
#     }
#     {
#         "Name": "tag-key",
#         "Values": ["Project"]
#     }
#     {
#         "Name": "tag-value",
#         "Values": ["LBDSD"]
#     }
#     {
#         "Name": "tag-key",
#         "Values": ["CanBeStopped"]
#     }
#     {
#         "Name": "tag-value",
#         "Values": ["true"]
#     }
# ]