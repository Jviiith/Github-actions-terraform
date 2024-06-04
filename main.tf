terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}


# 1. Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Ubuntu-VPC"
  }
}

# 2. Create an Internet gateway 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

}

# 3. Create a Route Table
resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Ubuntu-vpc-route"
  }
}

# 4. Create a Subnet 
resource "aws_subnet" "public-subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Ubuntu-public-subnet"
  }
}

# 5. Associate public subnet to Route table 
resource "aws_route_table_association" "public-route" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.route-table.id
}

# 6. Create a Security group to allow ports 22, 80, 443
resource "aws_security_group" "ubuntuSG" {
  name        = "UbuntuSG"
  description = "Allow SSH, HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
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

  tags = {
    Name = "UbuntuSG"
  }
}

# 7. Create an Linux server 
resource "aws_instance" "Ubuntu-server" {
  ami                         = "ami-0cf10cdf9fcd62d37"
  instance_type               = "t2.micro"
  availability_zone           = "us-east-1a"
  key_name                    = "ssh-server-key"
  vpc_security_group_ids      = [aws_security_group.ubuntuSG.id]
  subnet_id                   = aws_subnet.public-subnet.id
  associate_public_ip_address = true

  tags = {
    Name = "Ubuntu-Server"
  }
}
