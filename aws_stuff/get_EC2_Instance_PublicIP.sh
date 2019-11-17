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

aws ec2 describe-instances \
    --instance-ids "${INSTANCE_ID}" \
    | grep "PublicIp" \
    | head -n 1 \
    | awk '{print $2}' \
