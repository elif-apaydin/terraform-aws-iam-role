#!/bin/bash
KEYSTRING=$(sed -n 4p backend.tf | awk '{print $3}' | tr -d '"' | tr '-' " " | awk '{print $1}')
APPNAME=$(sed -n 3p vars.tf | awk '{print $3}' | tr -d '""')

if [ $KEYSTRING != $APPNAME ]; then
   echo "APPNAME and KEY is not equal"
   exit 1
else
    terraform init
    terraform validate
    terraform plan
    terraform apply -input=false -auto-approve
fi