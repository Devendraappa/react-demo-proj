variable "aws_region" {
  description = "AWS region where resources will be created"
  default     = "ap-south-1"
}

variable "s3_bucket_name" {
  description = "Base name for the S3 bucket"
  default     = "my-react-app"  # Base name without the random suffix
}

variable "aws_account_id" {
  description = "AWS Account ID for SNS and other resources"
  default     = "123456789012"
}

variable "role_name" {
  description = "IAM role name to assume in GitHub Actions"
  default     = "MyTerraformRole"
}
