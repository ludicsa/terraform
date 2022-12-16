provider "aws" {
  region = "us-east-1"
}

##VPC
resource "aws_vpc" "main" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "Main VPC"
  }

}

##SUBNET
resource "aws_subnet" "publicsubnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Public 1"
  }

}

resource "aws_subnet" "publicsubnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.publicsubnet2_cidr
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "Public 2"
  }

}
resource "aws_subnet" "privatesubnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private 1"
  }

}
resource "aws_subnet" "privatesubnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.5.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private 2"
  }

}

##IGW & NGW 
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Internet Gateway"
  }

}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.publicsubnet_1.id
  tags = {
    Name = "Nat Gateway"
  }

}

resource "aws_eip" "nat_gateway" {
  vpc = true

}

##ROUTE-TABLE
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "Private Route Table"
  }
}

##ROUTE-TABLE ASSOCIATION
resource "aws_route_table_association" "public_route_table_association_1" {
  subnet_id      = aws_subnet.publicsubnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_table_association_2" {
  subnet_id      = aws_subnet.publicsubnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_route_table_association_1" {
  subnet_id      = aws_subnet.privatesubnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_route_table_association_2" {
  subnet_id      = aws_subnet.privatesubnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

##SG
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "This SG allows SSH connection"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "These are the SSH rules"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "This SG allows HTTP connection"
  vpc_id      = aws_vpc.main.id


  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8090
    to_port     = 8090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "elb" {
  name        = "security_group_elb"
  vpc_id      = aws_vpc.main.id
  description = "elb security group"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


##S3 BUCKET
resource "aws_s3_bucket" "bucket-s3-final-theme" {
  bucket = "bucket-s3-final-theme"

  tags = {
    Name = "S3 Bucket Java Jar"
  }
}

resource "aws_s3_bucket_acl" "s3-acl" {
  bucket = aws_s3_bucket.bucket-s3-final-theme.id
  acl    = "private"
}

resource "aws_s3_object" "jar-object" {

  for_each = fileset("/home/ludicsa/artifacts/", "*")
  bucket   = aws_s3_bucket.bucket-s3-final-theme.id
  key      = each.value
  acl      = "private"
  source   = "/home/ludicsa/artifacts/${each.value}"

}


##JENKINS EC2
resource "aws_instance" "jenkins_server" {
  ami                    = var.instance_ami
  subnet_id              = aws_subnet.publicsubnet_2.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  availability_zone      = "us-east-1a"
  user_data              = file("/home/ludicsa/infra-aws/jenkins.sh")
  vpc_security_group_ids = [aws_security_group.allow_http.id, aws_security_group.allow_ssh.id]

  tags = {
    Name = var.jenkins_name

  }

}

##KEYPAIR
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "terraform_key" {
  key_name   = var.key_name
  public_key = tls_private_key.rsa_key.public_key_openssh
}

resource "local_file" "tfkey" {
  content         = tls_private_key.rsa_key.private_key_pem
  filename        = "tfkey"
  file_permission = "400"
}

module "autoscaling-elb" {
  source = "git@github.com:ludicsa/autoscaling-elb-module.git"

  instance_ami              = var.instance_ami
  instance_type             = var.instance_type
  privatesubnet_1           = aws_subnet.privatesubnet_1.id
  privatesubnet_2           = aws_subnet.privatesubnet_2.id
  desired_capacity          = var.desired_capacity
  min_size                  = var.min_size
  max_size                  = var.max_size
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  publicsubnet_1            = aws_subnet.publicsubnet_1.id
  publicsubnet_2            = aws_subnet.publicsubnet_2.id
  allow_http                = aws_security_group.allow_http.id
  allow_ssh                 = aws_security_group.allow_ssh.id
  elb                       = aws_security_group.elb.id
  vpc_id                    = aws_vpc.main.id
  port_http                 = var.port_http
  protocol_http             = var.protocol_http
  interval                  = var.interval
  healthy_threshold         = var.healthy_threshold
  unhealthy_threshold       = var.unhealthy_threshold
  timeout                   = var.timeout
  idle_timeout              = var.idle_timeout
  elb_name                  = var.elb_name
  target                    = var.target
  port_http_8080            = var.port_http_8080
  key_name                  = var.key_name


}
