provider "aws" {
  region = var.aws_region  # The region will now be set to "ap-south-1"
}

resource "random_id" "s3_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "react-app-${random_id.s3_id.hex}"  # Dynamically using random_id
  acl    = "public-read"
}
 
