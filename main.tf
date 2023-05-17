terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  access_key = ""
  secret_key = ""
  region     = ""
}

resource "aws_security_group" "allow_tls" {
  name        = "security_allow_all"
  description = "Allow TLS inbound traffic"
  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }

}


resource "aws_instance" "ec2amru" {
  ami                    = "ami-03d0155c1ef44f68a"
  instance_type          = "t3.micro"
  key_name               = "amru-sydney"
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  tags = {
    Name = "instance-name"
  }
}

output "ip_address" {
  value = aws_instance.ec2amru.public_ip
}

resource "aws_db_instance" "amru_rds" {
  db_name              = "people"
  engine               = "mysql"
  engine_version       = "8.0.32"
  instance_class       = "db.t3.small"
  username             = "people"
  password             = "people123"
  publicly_accessible  = true
  allocated_storage    = 10
  skip_final_snapshot  = true
  identifier           = "mysqldev"
}

output "db_ip_address" {
  value = aws_db_instance.amru_rds.address
}
