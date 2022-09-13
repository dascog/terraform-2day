provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}


resource "random_id" "server" {
  byte_length = 2
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.77.0"

  name                 = "${var.prefix}-${random_id.server.dec}-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_db_subnet_group" "sng" {
  name       = "${var.prefix}-${random_id.server.dec}-sng"
  subnet_ids = module.vpc.public_subnets

  # tags = {
  #   Name = "Education"
  # }
}

resource "aws_security_group" "rds" {
  name   = "${var.prefix}-${random_id.server.dec}-rds"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-${random_id.server.dec}-rds"
  }
}

# resource "aws_db_parameter_group" "pg" {
#   name   = "${var.prefix}-${random_id.server.dec}-pg"
#   family = "mysql8.0"

#   parameter {
#     name  = "character_set_server"
#     value = "utf8"
#   }
# }

resource "aws_db_instance" "db" {
  identifier             = "${var.prefix}-${random_id.server.dec}-db"
  instance_class         = "db.t2.micro"
  allocated_storage      = 5
  engine                 = "mariadb"
  engine_version         = "10.2.43"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.sng.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  //parameter_group_name   = aws_db_parameter_group.pg.name
  publicly_accessible    = true
  skip_final_snapshot    = true

  # provisioner "local-exec" {
  #   command = "mysql --host=${self.address} --port=${self.port} --user=${self.username} --password=${self.password} < ./schema.sql"
  # }
}
resource "null_resource" "setup_db" {
  depends_on = [aws_db_instance.db] #wait for the db to be ready
  provisioner "local-exec" {
    command = "mysql --host=${aws_db_instance.db.address} --port=${aws_db_instance.db.port} --user=${var.db_username} --password=${var.db_password} < ./schema.sql"
  }
}