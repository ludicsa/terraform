variable "provider_region" {
  default     = "us-east-1"
  description = "Terraform provider region"

}

variable "vpc_cidr" {
  default     = "10.10.0.0/16"
  description = "VPC cidr block"

}

variable "public1_cidr" {
  default     = "10.10.1.0/24"
  description = "Public subnet 1 cidr block"

}

variable "public2_cidr" {
  default     = "10.10.2.0/24"
  description = "Public subnet 2 cidr block"

}

variable "private1_cidr" {
  default     = "10.10.4.0/24"
  description = "Private subnet 1 cidr block"

}

variable "private2_cidr" {
  default     = "10.10.5.0/24"
  description = "Private subnet 2 cidr block"

}

variable "private3_cidr" {
  default     = "10.10.6.0/24"
  description = "Private subnet 3 cidr block"

}

variable "private4_cidr" {
  default     = "10.10.7.0/24"
  description = "Private subnet 4 cidr block"

}

variable "rt_cidr" {
  default     = "0.0.0.0/0"
  description = "Private subnet 1 cidr block"

}

variable "az_a" {
  default     = "us-east-1a"
  description = "Availability zone us-east-1a"

}

variable "az_b" {
  default     = "us-east-1b"
  description = "Availability zone us-east-1b"

}

variable "key_name" {
  default     = "terraform_key"
  description = "Key pair name"

}

variable "key_algorithm" {
  default     = "RSA"
  description = "Key pair algorithm"

}

variable "instance_ami" {
  default     = "ami-00874d747dde814fa"
  description = "Bastion AMI"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "Type of the instance"

}

##ALB

variable "alb" {
  type = object({
    alb_port_http    = number
    alb_idle_timeout = number
    alb_name         = string
    alb_port_http    = string
  })

  default = {
    alb_port_http    = 80
    alb_idle_timeout = 40
    alb_name         = "ALB"
    alb_port_http    = "8080"
  }
}

#ASG
variable "asg" {
  type = object({
    asg_desired_capacity          = number
    asg_min_size                  = number
    asg_max_size                  = number
    asg_health_check_grace_period = number
    asg_health_check_type         = string
  })

  default = {
    asg_desired_capacity          = 2
    asg_min_size                  = 1
    asg_max_size                  = 2
    asg_health_check_grace_period = 300
    asg_health_check_type         = "EC2"
  }
}


##DB
variable "database" {
  type = object({
    db_subnet_group_name = string
    db_engine_version    = string
    db_instance_class    = string
    db_username          = string
    db_password          = string
    db_port              = number
    db_engine            = string
    db_name              = string
  })

  default = {
    db_subnet_group_name = "db-subnet-group"
    db_engine_version    = "14.6"
    db_instance_class    = "db.t3.micro"
    db_username          = "root"
    db_password          = "root1234"
    db_port              = 5432
    db_engine            = "postgres"
    db_name              = "postgresdb"
  }
}
