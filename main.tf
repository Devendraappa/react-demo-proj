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
  acl    = "private"  # ACL setting, no longer conflicting with ownership settings

  # Enable static website hosting
  website {
    index_document = "index.html"
  }
}

# Upload React App build files to S3
resource "aws_s3_bucket_object" "react_app_files" {
  for_each = fileset("./build", "**/*")
  bucket   = aws_s3_bucket.react_app_bucket.bucket
  key      = each.key
  source   = "./build/${each.key}"
  acl      = "public-read"
}

# CloudFront Distribution for React App
resource "aws_cloudfront_distribution" "react_app_distribution" {
  origin {
    domain_name = aws_s3_bucket.react_app_bucket.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.react_app_bucket.id}"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/EXAMPLE"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "React App CloudFront Distribution"
  default_root_object = "index.html"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id       = "S3-${aws_s3_bucket.react_app_bucket.id}"

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  # Optional Logging Configuration
  logging_config {
    include_cookies = false
    bucket           = "${aws_s3_bucket.react_app_bucket.bucket}.s3.amazonaws.com"
    prefix           = "cloudfront-logs/"
  }

  price_class = "PriceClass_100"
}
