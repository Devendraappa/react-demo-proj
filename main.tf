provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "app_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = "ReactAppInstance"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Update the instance
              sudo apt-get update -y
              sudo apt-get upgrade -y
              
              # Install Node.js and npm
              curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
              sudo apt-get install -y nodejs

              # Install Git
              sudo apt-get install -y git

              # Clone the GitHub repository
              git clone https://github.com/Devendraappa/react-demo-proj.git /home/ubuntu/react-demo-proj
              cd /home/ubuntu/react-demo-proj

              # Run application commands
              npm install
              npm run build
              npm test
              
              # Start the application (example: serve using npm or a process manager like PM2)
              npm start > /dev/null 2>&1 &
              EOF

  security_groups = [aws_security_group.app_sg.name]
}

resource "aws_security_group" "app_sg" {
  name        = "react-app-sg"
  description = "Allow SSH and HTTP access"

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

  tags = {
    Name = "ReactAppSG"
  }
}

# Output the public IP of the EC2 instance
output "ec2_instance_public_ip" {
  value = aws_instance.app_instance.public_ip
}

output "ec2_instance_public_dns" {
  value = aws_instance.app_instance.public_dns
}
