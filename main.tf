provider "aws" {
  region = var.aws_region
}

# Create a VPC if not exists
resource "aws_vpc" "default_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "default-vpc"
  }
}

# Create a subnet in the created VPC
resource "aws_subnet" "default_subnet" {
  vpc_id                  = aws_vpc.default_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.aws_region_availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "default-subnet"
  }
}

# Security Group for EC2
resource "aws_security_group" "nodejs_sg" {
  name        = "nodejs-sg"
  description = "Allow inbound SSH and HTTP traffic"
  vpc_id      = aws_vpc.default_vpc.id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nodejs_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name  # Using the key pair name from the variable
  security_groups        = [aws_security_group.nodejs_sg.name]  # Corrected here
  subnet_id             = aws_subnet.default_subnet.id
  associate_public_ip_address = true

  tags = {
    Name = "NodeJS-App-EC2"
  }

  # Provisioning script to deploy the Node.js app
  user_data = <<-EOT
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y git
              curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
              sudo yum install -y nodejs
              cd /home/ec2-user
              git clone https://github.com/Devendraappa/react-demo-proj.git
              cd react-demo-proj
              npm ci
              npm test
              npm run build
              EOT
}

# Output EC2 Public IP
output "ec2_public_ip" {
  value = aws_instance.nodejs_instance.public_ip
}
