provider "aws" {
  region = "ap-south-1"
}

# Generate a random ID for the bucket name
resource "random_id" "id" {
  byte_length = 8
}

# S3 Bucket resource for React App
resource "aws_s3_bucket" "react_app_bucket" {
  bucket = "react-demo-app-bucket-${random_id.id.hex}"

  # Enable static website hosting
  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  # Enable public access
  acl = "public-read"
}

# Disable BlockPublicAcls and BlockPublicPolicy settings
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.react_app_bucket.id

  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls  = false
  restrict_public_buckets = false
}

# Enable versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.react_app_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Bucket policy to allow public read access
resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.react_app_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.react_app_bucket.arn}/*"
      }
    ]
  })
}

# Upload React App build files to S3
resource "aws_s3_bucket_object" "react_app_files" {
  for_each = fileset("./dist", "**/*")
  bucket   = aws_s3_bucket.react_app_bucket.bucket
  key      = each.key
  source   = "./dist/${each.key}"
  acl      = "public-read"
}

# Output the S3 bucket website URL
output "s3_bucket_website_url" {
  value = aws_s3_bucket.react_app_bucket.website_endpoint
}
