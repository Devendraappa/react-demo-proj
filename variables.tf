variable "aws_region" {
  default = "ap-south-1"
}

variable "ami_id" {
  default = "ami-00bb6a80f01f03502" # Replace with the correct AMI ID for your region
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "desktop" # Replace with your actual key pair name
}
