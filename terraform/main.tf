terraform {
  required_providers { aws = { source = "hashicorp/aws", version = ">=5.0" } }
  required_version = ">=1.4.0"
}

provider "aws" {}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16" 
  enable_dns_hostnames = true
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}
variable "ami_id" {
  type    = string
  default = "ami-0e2c8caa4b6378d8c" 
}


resource "aws_subnet" "public_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24" 
  availability_zone = "us-east-1" 
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "public_a" {
  subnet_id = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "natgw" {
  subnet_id = aws_subnet.public_a.id
  allocation_id = aws_eip.nat.id
}


resource "aws_subnet" "private_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24" 
  availability_zone = "us-east-1"
  map_public_ip_on_launch = false
  tags = { Name = "${var.name_prefix}-private-a" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }
  tags = { Name = "${var.name_prefix}-private-rt" }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
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
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name_prefix}-sg" }
}

resource "aws_instance" "backend" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = aws_subnet.private_a.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  associate_public_ip_address = false
  key_name = var.key_name != "" ? var.key_name : null
  user_data = file("${path.module}/script_backend.sh")
  tags = { Name = "${var.name_prefix}-backend" }
}

resource "aws_instance" "frontend" {
  ami = var.ami_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg.id]
  subnet_id = aws_subnet.public_a.id
  associate_public_ip_address = true
  key_name = var.key_name != "" ? var.key_name : null
  
  user_data = templatefile("${path.module}/script_frontend.sh", {
    backend_ip = aws_instance.backend.private_ip
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