variable "instance_ami" {
  default     = "ami-08c40ec9ead489470"
  description = "Instances AMI"

}

variable "instance_type" {
  default     = "t2.micro"
  description = "Type of the instance"

}

variable "publicsubnet2_cidr" {
  default     = "10.10.2.0/24"
  description = "Public subnet 2 cidr block"

}


variable "jenkins_name" {
  default     = "Jenkins Server"
  description = "Name of the instance"

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
