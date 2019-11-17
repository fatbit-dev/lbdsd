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

if [ "$#" -ne 1  ]; then
    usage
    exit 1
fi

INSTANCE_ID="${1}"

aws ec2 stop-instances \
    --instance-ids "${INSTANCE_ID}"

# aws opsworks stop-instance \
#     --region us-west-1 \
#     --instance-id "${INSTANCE_ID}"

