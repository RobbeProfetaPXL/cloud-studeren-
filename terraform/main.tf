terraform {
  required_providers { aws = { source = "hashicorp/aws", version = ">=5.0" } }
  required_version = ">=1.4.0"
}

provider "aws" {}

variable "ami_id" {
  type    = string
  default = "ami-0e2c8caa4b6378d8c" 
}

resource "aws_security_group" "sg" {
  name_prefix = "${var.name_prefix}-sg-"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.name_prefix}-sg" }
}

resource "aws_instance" "database" {
  ami = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg.id]
  associate_public_ip_address = true
  key_name = var.key_name != "" ? var.key_name : null
  user_data = file("${path.module}/script_database.sh")
  tags = { Name = "${var.name_prefix}-database" }
}

resource "aws_instance" "backend" {
  ami = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg.id]
  associate_public_ip_address = true
  key_name = var.key_name != "" ? var.key_name : null
  user_data = templatefile("${path.module}/script_backend.sh", {
    mongo_url = "mongodb://${aws_instance.database.private_ip}:27017/todoapp?directConnection=true"
  })
  tags = { Name = "${var.name_prefix}-backend" }
}

resource "aws_instance" "frontend" {
  ami = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg.id]
  associate_public_ip_address = true
  key_name = var.key_name != "" ? var.key_name : null
  
  user_data = templatefile("${path.module}/script_frontend.sh", {
    backend_ip = aws_instance.backend.public_ip
  })
  tags = { Name = "${var.name_prefix}-frontend" }
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type    = string
  default = "test"
}

variable "name_prefix" {
  type    = string
  default = "todoapp"
}


output "backend_public_ip" { 
  value = aws_instance.backend.public_ip 
}

output "frontend_public_ip" { 
  value = aws_instance.frontend.public_ip 
}