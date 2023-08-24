packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.2.6"
    }
  }
}

variable "ami_id" {
  type    = string
  default = "ami-06878d265978313ca"
}


source "amazon-ebs" "java" {
  ami_name      = "packer-application-{{timestamp}}"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami    = "${var.ami_id}"
  ssh_username  = "ubuntu"
  tags = {
    Env  = "dev"
    Name = "packer"
  }
}

build {

  sources = ["source.amazon-ebs.java"]

  provisioner "shell" {
    script = "../../terraform/terraform/packer/java.sh"
  }

  provisioner "file" {
    source      = "../../terraform/terraform/artifacts/myapp.jar"
    destination = "/opt/deployment/myapp.jar"
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}