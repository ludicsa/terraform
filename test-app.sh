PUBLIC_IP=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].PublicIpAddress" --output=text)

scp -pr -i tfkey /home/ludicsa/.aws/ ubuntu@$PUBLIC_IP:/home/ubuntu/.aws/
scp -i tfkey /home/ludicsa/terraform/.bashrc ubuntu@$PUBLIC_IP:~

ssh -a -i tfkey ubuntu@$PUBLIC_IP
