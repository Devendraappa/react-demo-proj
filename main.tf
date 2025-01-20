provider "aws" {
  region = var.aws_region
}

# Security Group for EC2
resource "aws_security_group" "nodejs_sg" {
  name        = "nodejs-sg"
  description = "Allow inbound SSH and HTTP traffic"
  vpc_id      = var.vpc_id

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

# EC2 Instance
resource "aws_instance" "nodejs_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_pair_name  # Using the key pair name from the variable
  security_group         = aws_security_group.nodejs_sg.name
  subnet_id             = var.subnet_id
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
