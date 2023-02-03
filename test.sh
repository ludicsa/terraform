export PUBLICIP
PUBLICIP=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].PublicIpAddress" --output=text 2>/dev/null)

scp -i tfkey -o StrictHostKeyChecking=no /home/ludicsa/terraform/.bashrc ubuntu@$PUBLICIP:~


ssh -i tfkey -o StrictHostKeyChecking=no ubuntu@$PUBLICIP 2>/dev/null