packer {
    required_plugins {
        amazon = {
            version = ">= 1.0.0"
            source  = "github.com/hashicorp/amazon"
        }
    }
}

source "amazon-ebs" "asg-ami" {
    ami_name = "asg-ami"
    source_ami = "ami-0574da719dca65348"
    instance_type = "t2.micro"
    region = "us-east-1"
    ssh_username = "ubuntu"

}

build {
    sources = [
        "source.amazon-ebs.asg-ami"
    ]

    provisioner "shell" {
        script "./app.sh"
    }  

}