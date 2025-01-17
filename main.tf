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
    error_document = "index.html"
  }
}

# Upload React App build files to S3
resource "aws_s3_bucket_object" "react_app_files" {
  for_each = fileset("./dist", "**/*")
  bucket   = aws_s3_bucket.react_app_bucket.bucket
  key      = each.key
  source   = "./dist/${each.key}"
  # Remove the ACL setting
}

# Output the S3 bucket website URL
output "s3_bucket_website_url" {
  value = aws_s3_bucket.react_app_bucket.website_endpoint
}
