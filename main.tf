provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "react-app-${random_id.s3_id.hex}"
  acl    = "public-read"
}

resource "random_id" "s3_id" {
  byte_length = 8
}

# You can add more resources like CloudFront, S3 object deployment, etc., if needed.
