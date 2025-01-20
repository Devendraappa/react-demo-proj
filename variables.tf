# AWS Region
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

# AMI ID for EC2 instance
variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

# EC2 Instance Type
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Subnet ID for the EC2 instance
variable "subnet_id" {
  description = "The subnet ID in which the EC2 instance will be created"
  type        = string
}

# VPC ID
variable "vpc_id" {
  description = "The VPC ID where the security group will be applied"
  type        = string
}

# Path to the public key for EC2 instance
variable "public_key_path" {
  description = "Path to the SSH public key file for EC2 instance"
  type        = string
}
