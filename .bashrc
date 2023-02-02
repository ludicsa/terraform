#!/bin/bash
sudo apt update -y && sudo DEBIAN_FRONTEND=noninteractive apt-get -yq install awscli

ENDPOINT=$(aws --region us-east-1 ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=App Server" --query 'Reservations[*].Instances[*].[PrivateIpAddress]' --output text 2>/dev/null)

curl $ENDPOINT:8080/actuator/health 2>/dev/null





