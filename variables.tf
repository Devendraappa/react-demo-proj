# AWS Region for resource deployment
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"  # Update this to your desired region
}

# S3 Bucket Name
variable "s3_bucket_name" {
  description = "Name of the S3 bucket where the app will be deployed"
  type        = string
  default     = "react-app-${random_id.s3_id.hex}"  # This will be used in your main.tf for dynamic naming
}

