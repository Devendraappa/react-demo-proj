provider "aws" {
  region = var.aws_region
}

# Create a security group for the EC2 instance
resource "aws_security_group" "ec2_security_group" {
  name        = var.security_group_name
  description = "Allow HTTP and SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH access from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP access from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance
resource "aws_instance" "web_server" {
  ami           = "ami-0cda377a1b884a1bc"  # Amazon Linux 2 AMI in ap-south-1
  instance_type = var.instance_type
  key_name      = var.key_name

  # Attach the security group
  security_groups = [aws_security_group.ec2_security_group.name]

  # User data to install Node.js and deploy the app
  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y nodejs npm
    git clone https://github.com/Devendraappa/react-demo-proj.git /home/ec2-user/react-demo-proj
    cd /home/ec2-user/react-demo-proj
    npm install
    nohup npm start &
  EOF

  tags = {
    Name = "React-App-Server"
  }
}

# Output public IP of the EC2 instance
output "ec2_public_ip" {
  value = aws_instance.web_server.public_ip
  description = "Public IP of the EC2 instance"
}
