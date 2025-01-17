provider "aws" {
  region = "ap-south-1"
}

# S3 Bucket resource for React App
resource "aws_s3_bucket" "react_app_bucket" {
  bucket = "react-demo-app-bucket9659"

  # Add bucket ownership control to enforce bucket owner control
  bucket_ownership_controls {
    rule {
      object_ownership = "BucketOwnerEnforced"
    }
  }

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

# CloudFront Distribution resource for serving React app from S3
resource "aws_cloudfront_distribution" "react_app_distribution" {
  origin {
    domain_name = aws_s3_bucket.react_app_bucket.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.react_app_bucket.id}"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/EXAMPLE"  # Replace with actual OAI if needed
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "React App CloudFront Distribution"
  default_root_object = "index.html"

  # Add Restrictions block (optional, add if needed)
  restrictions {
    geo_restriction {
      restriction_type = "none"  # Change as per region restrictions
    }
  }

  # Add Viewer Certificate block (optional if using custom domain)
  viewer_certificate {
    cloudfront_default_certificate = true  # Use CloudFront's default SSL certificate
    # Uncomment below for custom SSL
    # acm_certificate_arn = "arn:aws:acm:region:account-id:certificate/certificate-id"
    # ssl_support_method = "sni-only"
  }

  # Default Cache Behavior with required arguments
  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    target_origin_id      = "S3-${aws_s3_bucket.react_app_bucket.id}"

    allowed_methods = ["GET", "HEAD"]  # Correct format for allowed_methods
    cached_methods  = ["GET", "HEAD"]  # Correct format for cached_methods

    forwarded_values {
      query_string = false  # Set to true if query string forwarding is needed

      cookies {
        forward = "none"  # Adjust if you need cookie forwarding
      }
    }
  }

  # Optional Logging Configuration
  logging_config {
    include_cookies = false
    bucket           = "your-log-bucket-name.s3.amazonaws.com"  # Replace with actual log bucket name
    prefix           = "cloudfront-logs/"
  }

  price_class = "PriceClass_100"  # Adjust price class based on your requirements
}
