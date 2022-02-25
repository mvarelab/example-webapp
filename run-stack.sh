#!/bin/bash
set -e
set -x

STACK_NAME=$1
ALB_LISTENER_ARN=$2

if ! aws cloudformation describe-stacks --region eu-west-3 --stack-name $STACK_NAME 2>&1 > /dev/null
then
    finished_check=stack-create-complete
else
    finished_check=stack-update-complete
fi

aws cloudformation deploy \
    --region eu-west-3 \
    --stack-name $STACK_NAME \
    --template-file service.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides \
    "DockerImage=0792459632633.dkr.ecr.eu-west-3.amazonaws.com/example-webapp:$(git rev-parse HEAD)" \
    "VPC=vpc-0415530b42e3c9740" \
    "Subnet=subnet-0ab67d7f59b4cd98a" \
    "Cluster=default" \
    "Listener=$ALB_LISTENER_ARN"

aws cloudformation wait $finished_check --region eu-west-3 --stack-name $STACK_NAME
