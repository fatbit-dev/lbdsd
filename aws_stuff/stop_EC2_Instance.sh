#!/bin/bash

error() {
  echo -e "\e[31m $@ \e[0m"
}

usage() {
	error ">>> Error: ${0} needs one argument:"
	echo -e ">>>   - AWS EC2 Instance ID"
	echo -e ">>> Example:"
	echo -e ">>> \t${0} 3a21cfac-4a1f-4ce2-a921-b2cfba6f7771"
}

if [ "$#" -ne 1  ]; then
	usage
	exit 1
fi

INSTANCE_ID="${1}"

aws opsworks stop-instance \
	--region us-west-1 \
	--instance-id "${INSTANCE_ID}"
