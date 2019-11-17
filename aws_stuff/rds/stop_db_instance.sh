#!/bin/bash

warning() {
    echo -e "\e[33m $@ \e[0m"
}

usage() {
    warning ">>> Warning: ${0} is using a default DB Instance Id."
    echo -e ">>> Rember you can provide an AWS DB Instance Id."
    echo -e ">>> Example:"
    echo -e ">>> \t${0} my-database-dev"
}

DB_REGION='eu-west-1'
DB_INSTANCE_ID=""

if [ "$#" -gt 0 ]; then
    DB_INSTANCE_ID="${1}"
else
    DB_INSTANCE_ID='lbdsd-db'
    usage
fi

aws rds stop-db-instance \
    --region ${DB_REGION} \
    --db-instance-identifier "${INSTANCE_ID}"
