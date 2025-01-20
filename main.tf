provider "aws" {
  region = var.aws_region
}

# Generate a unique ID for the S3 bucket to avoid name duplication
resource "random_id" "bucket_id" {
  byte_length = 8  # Generates a random 8-byte ID
}

# S3 Bucket for Hosting the React App with a random unique suffix
resource "aws_s3_bucket" "react_app" {
  bucket = "${var.s3_bucket_name}-${random_id.bucket_id.hex}"  # Append the random ID to the bucket name
  acl    = "public-read"

  website {
    index_document = "index.html"
    # error_document = "error.html"  # Uncomment if you want custom error page
  }
}

# Output the S3 bucket name to use in GitHub Actions
output "s3_bucket_name" {
  value = aws_s3_bucket.react_app.bucket
}

# IAM Role and Policy to allow access to the S3 bucket (optional)
resource "aws_iam_role" "s3_role" {
  name = "s3_bucket_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "s3_policy" {
  name = "s3_bucket_access_policy"
  role = aws_iam_role.s3_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Effect   = "Allow"
      Resource = [
        "${aws_s3_bucket.react_app.arn}/*",
        "${aws_s3_bucket.react_app.arn}"
      ]
    }]
  })
}
