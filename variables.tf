# AWS Region
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

# Availability Zone within the region for subnet
variable "aws_region_availability_zone" {
  description = "The availability zone to create the subnet in"
  type        = string
  default     = "ap-south-1a"  # Change this if needed
}

# AMI ID for EC2 instance
variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-00bb6a80f01f03502"  # Example for Amazon Linux 2 (adjust for the region)
}

# EC2 Instance Type
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Key Pair Name for EC2 instance
variable "key_pair_name" {
  description = "The name of the existing key pair for EC2 instance"
  type        = string
  default     = "desktop"  # Replace with your key pair name in AWS
}
