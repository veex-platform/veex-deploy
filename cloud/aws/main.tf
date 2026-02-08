provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t3.medium"
}

resource "aws_vpc" "veex_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "veex-vpc" }
}

resource "aws_subnet" "veex_subnet" {
  vpc_id     = aws_vpc.veex_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = { Name = "veex-subnet" }
}

resource "aws_internet_gateway" "veex_gw" {
  vpc_id = aws_vpc.veex_vpc.id
  tags = { Name = "veex-gateway" }
}

resource "aws_route_table" "veex_rt" {
  vpc_id = aws_vpc.veex_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.veex_gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.veex_subnet.id
  route_table_id = aws_route_table.veex_rt.id
}

resource "aws_security_group" "veex_sg" {
  name        = "veex-sg"
  vpc_id      = aws_vpc.veex_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "veex_server" {
  ami           = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS
  instance_type = var.instance_type
  subnet_id     = aws_subnet.veex_subnet.id
  vpc_security_group_ids = [aws_security_group.veex_sg.id]

  tags = { Name = "veex-platform-server" }
}

output "public_ip" {
  value = aws_instance.veex_server.public_ip
}
