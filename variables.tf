# AWS Region for resource deployment
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"  # Updated to Mumbai region (ap-south-1)
}

# S3 Bucket Name (we won't set it dynamically here, instead use random_id in main.tf)
variable "s3_bucket_name" {
  description = "Name of the S3 bucket where the app will be deployed"
  type        = string
}
