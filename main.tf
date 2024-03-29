terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }
  }
  backend "s3" {
    bucket = "s3-backend-project-ilegra"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.provider_region
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "Main VPC"
  }

}

resource "aws_subnet" "publicsubnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public1_cidr
  availability_zone       = var.az_b
  map_public_ip_on_launch = true

  tags = {
    Name = "Public 1"
  }

}

resource "aws_subnet" "publicsubnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public2_cidr
  availability_zone = var.az_a

  tags = {
    Name = "Public 2"
  }

}
resource "aws_subnet" "privatesubnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private1_cidr
  availability_zone = var.az_b

  tags = {
    Name = "Private 1"
  }

}
resource "aws_subnet" "privatesubnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private2_cidr
  availability_zone = var.az_a

  tags = {
    Name = "Private 2"
  }

}

resource "aws_subnet" "privatesubnet_3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private3_cidr
  availability_zone = var.az_b

  tags = {
    Name = "Private 3"
  }

}

resource "aws_subnet" "privatesubnet_4" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private4_cidr
  availability_zone = var.az_a

  tags = {
    Name = "Private 4"
  }

}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "IGW"
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

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.rt_cidr
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = var.rt_cidr
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "Private Route Table"
  }
}

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

resource "aws_route_table_association" "private_route_table_association_3" {
  subnet_id      = aws_subnet.privatesubnet_3.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_route_table_association_4" {
  subnet_id      = aws_subnet.privatesubnet_4.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "This SG allows SSH connection"
  vpc_id      = aws_vpc.main.id

  ingress {
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

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "alb" {
  name        = "security_group_alb"
  vpc_id      = aws_vpc.main.id
  description = "alb security group"
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

resource "aws_launch_template" "ec2_config" {
  image_id               = data.aws_ami.java-ami.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  user_data              = filebase64("./user-data.sh")
  update_default_version = true

  lifecycle {
    create_before_destroy = true
  }

  network_interfaces {
    security_groups             = [aws_security_group.allow_http.id, aws_security_group.allow_ssh.id, aws_security_group.alb.id]
    associate_public_ip_address = false
  }
}

resource "aws_autoscaling_group" "auto_scaling_group" {
  name                      = "Auto Scaling Group"
  vpc_zone_identifier       = [aws_subnet.privatesubnet_1.id, aws_subnet.privatesubnet_2.id]
  desired_capacity          = var.desired_capacity
  min_size                  = var.min_size
  max_size                  = var.max_size
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type

  tag {
    propagate_at_launch = true
    key                 = "Name"
    value               = "Aplication Server Java"
  }


  launch_template {
    id      = aws_launch_template.ec2_config.id
    version = aws_launch_template.ec2_config.latest_version



  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      skip_matching          = false
    }
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.auto_scaling_group.id
  alb_target_group_arn   = aws_lb_target_group.target_group.arn
}

data "aws_ami" "java-ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["packer-application-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_lb" "application-load-balancer" {
  name            = var.alb_name
  subnets         = [aws_subnet.publicsubnet_1.id, aws_subnet.publicsubnet_2.id]
  security_groups = [aws_security_group.alb.id]

  tags = {
    Name = "Application Load Balancer"
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.application-load-balancer.arn
  port              = var.port_http
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.target_group.arn
    type             = "forward"

    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "OK"
    }
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "my-target-group"
  port        = var.port_http_8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id = aws_vpc.main.id

  health_check {
    path = "/actuator/health"
  }
}


resource "aws_db_subnet_group" "db-subnet-group" {
  name       = var.database.db_subnet_group_name
  subnet_ids = [aws_subnet.privatesubnet_3.id, aws_subnet.privatesubnet_4.id]

  tags = {
    "Name" = var.database.db_subnet_group_name
  }

}
resource "aws_db_instance" "postgres-db" {
  skip_final_snapshot  = true
  multi_az             = true
  db_subnet_group_name = aws_db_subnet_group.db-subnet-group.name
  allocated_storage    = 10
  engine               = var.database.db_engine
  engine_version       = var.database.db_engine_version
  instance_class       = var.database.db_instance_class
  db_name              = var.database.db_name
  username             = var.database.db_username
  port                 = var.database.db_port
  password             = var.database.db_password

  vpc_security_group_ids = [aws_security_group.allow_http.id, aws_security_group.allow_ssh.id]
}

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


