provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "react_app_bucket" {
  bucket = "react-demo-app-bucket9659"
  acl    = "public-read"
}

resource "aws_s3_bucket_object" "react_app_files" {
  for_each = fileset("./build", "**/*")
  bucket   = aws_s3_bucket.react_app_bucket.bucket
  key      = each.key
  source   = "./build/${each.key}"
  acl      = "public-read"
}

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

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id      = "S3-${aws_s3_bucket.react_app_bucket.id}"

    allowed_methods {
      cached_methods = ["GET", "HEAD"]
      methods        = ["GET", "HEAD"]
    }

    forwarded_values {
      query_string = false
    }
  }
}
