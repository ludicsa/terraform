export PUBLICIP
PUBLICIP=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].PublicIpAddress" --output=text 2>/dev/null)
echo $PUBLICIP >> ip.txt

IP=$(<ip.txt)

scp -i tfkey -o StrictHostKeyChecking=no /home/ludicsa/terraform/.bashrc ubuntu@$IP:~


ssh -i tfkey -o StrictHostKeyChecking=no ubuntu@$IP 2>/dev/null