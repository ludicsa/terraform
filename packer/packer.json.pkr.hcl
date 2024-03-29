variable "ami_id" {
  type    = string
  default = "ami-0261755bbcb8c4a84"
}


source "amazon-ebs" "java" {
  ami_name      = "packer-application-{{timestamp}}"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami    = "${var.ami_id}"
  ssh_username  = "ubuntu"
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