# AWS Region for resource deployment
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"  # Mumbai region
}

# EC2 Instance Type
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Key pair name for accessing the instance
variable "key_name" {
  description = "Name of the key pair to use for SSH access"
  type        = string
}

# Security group name
variable "security_group_name" {
  description = "Name of the security group for the EC2 instance"
  type        = string
  default     = "ec2-security-group"
}
