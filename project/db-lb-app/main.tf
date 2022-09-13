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

# Obtain a region independent list of availability zones
data "aws_availability_zones" "all" {
  state = "available"
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

# Security Group for the load balancer
resource "aws_security_group" "elb-sg" {
  name = "${var.prefix}-${random_id.server.dec}-elb_sg"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Security group for the instances
resource "aws_security_group" "instance-sg" {
  name = "${var.prefix}-${random_id.server.dec}-instance-sg"
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

# resource "aws_key_pair" "ssh_key" {
#   key_name = "ssh_key"
#   public_key = file("ssh_key.pub")
# }

# The Launch Configuration
resource "aws_launch_configuration" "my_launch_config" {
  name = "launch_config_${var.prefix}_${random_id.server.dec}"
  image_id               = data.aws_ami.amazon_linux.image_id
  instance_type          = var.instance_type
  # For now use the same SG as the ELB. This could be changed for a different one to prevent direct access
  security_groups        = [aws_security_group.instance-sg.id]
  # key_name               = aws_key_pair.ssh_key.key_name
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

  lifecycle {
    create_before_destroy = true
  }
}

# The autoscaling group
## Creating AutoScaling Group
resource "aws_autoscaling_group" "example" {
  name = "asg_${var.prefix}_${random_id.server.dec}"
  launch_configuration = aws_launch_configuration.my_launch_config.id
  min_size = var.minimum_size
  max_size = var.maximum_size
  load_balancers = [aws_elb.my-elb.name]
  availability_zones = data.aws_availability_zones.all.names
  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "My Terraform Deployment"
    propagate_at_launch = true
  }
}

# The Load balancer
resource "aws_elb" "my-elb" {
  name = "elb-${var.prefix}-${random_id.server.dec}"
  security_groups = [aws_security_group.elb-sg.id]
  availability_zones = data.aws_availability_zones.all.names
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:8080/api/"
  }
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "8080"
    instance_protocol = "http"
  }
}

# resource "aws_instance" "web" {
#   ami           = data.aws_ami.amazon_linux.id
#   security_groups        = ["${aws_security_group.web-sg.name}"]
 
#   instance_type = var.instance_type

#   user_data = <<-EOT
#                 #!/bin/bash
#                 yum update -y
#                 yum -y install java-1.8.0
#                 yum install ec2-instance-connect
#                 cd /home/ec2-user
#                 cat <<-EOF > application.properties
#                 spring.datasource.url=jdbc:mysql://cloudessentialsworkshop.cfw1ttrlhzus.eu-west-2.rds.amazonaws.com:3306/conygre?useSSL=false
#                 spring.datasource.username=root
#                 spring.datasource.password=c0nygre1
#                 EOF
#                 wget ${var.jarfile_url}
#                 nohup java -jar ${var.jarfile_name} > ec2dep.log
#                 EOT

#   tags = {
#     Name = "${var.prefix}-${random_id.server.id}"
#   }
# }