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
  description = "Private subnet 1 cidr block"

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
  default     = "ami-05f9fdacb4f4ec950"
  description = "Instances AMI"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "Type of the instance"

}

##ASG & ELB
variable "desired_capacity" {
  default     = 2
  description = "Desired ASG capacity"

}

variable "min_size" {
  default     = 1
  description = "Min size ASG capacity"

}

variable "max_size" {
  default     = 2
  description = "Max size ASG capacity"

}

variable "health_check_grace_period" {
  default     = 300
  description = "Health check period"

}

variable "health_check_type" {
  default     = "EC2"
  description = "Health check type"

}

variable "port_http" {
  default     = 80
  description = "HTTP"

}

variable "protocol_http" {
  default     = "http"
  description = "http Protocol"

}

variable "interval" {
  default     = 10
  description = ""

}

variable "timeout" {
  default     = 5
  description = ""

}

variable "healthy_threshold" {
  default     = 5
  description = ""

}

variable "unhealthy_threshold" {
  default     = 5
  description = ""

}

variable "target" {
  default     = "HTTP:8080/actuator/health"
  description = ""

}

variable "idle_timeout" {
  default     = 40
  description = ""

}

variable "elb_name" {
  default     = "ELB"
  description = ""
}

variable "port_http_8080" {
  default     = "8080"
  description = ""

}
