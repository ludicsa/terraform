variable "ami_id" {
  type    = string
  default = "ami-06878d265978313ca"
}

locals {
  app_name = "application-java_v6"
}

source "amazon-ebs" "java" {
  ami_name      = "packer-${local.app_name}"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami    = "${var.ami_id}"
  ssh_username  = "ubuntu"
  tags = {
    Env  = "dev"
    Name = "packer-${local.app_name}"
  }
}

build {

  sources = ["source.amazon-ebs.java"]

  provisioner "shell" {
    script = "./java.sh"
  }

  provisioner "file" {
    source      = "/home/ludicsa/terraform/artifacts/myapp.jar"
    destination = "/opt/deployment/myapp.jar"
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}