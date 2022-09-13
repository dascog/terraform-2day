terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.aws_region
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "random_id" "server" {
  byte_length = 4
}

resource "aws_security_group" "web-sg" {
  name = "${var.prefix}-${random_id.server.id}-sg"
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# data "terraform_remote_state" "db" {
#   backend = "local"
#   config = {
#     path = "../db/terraform.tfstate"
#    }
# }


resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  security_groups        = ["${aws_security_group.web-sg.name}"]
 
  instance_type = var.instance_type

  user_data = <<-EOT
                #!/bin/bash
                yum update -y
                yum -y install java-1.8.0
                yum install ec2-instance-connect
                cd /home/ec2-user
                cat <<-EOF > application.properties
                spring.datasource.url=jdbc:mysql://cloudessentialsworkshop.cfw1ttrlhzus.eu-west-2.rds.amazonaws.com:3306/conygre?useSSL=false
                spring.datasource.username=root
                spring.datasource.password=c0nygre1
                EOF
                wget ${var.jarfile_url}
                nohup java -jar ${var.jarfile_name} > ec2dep.log
                EOT

  tags = {
    Name = "${var.prefix}-${random_id.server.id}"
  }
}