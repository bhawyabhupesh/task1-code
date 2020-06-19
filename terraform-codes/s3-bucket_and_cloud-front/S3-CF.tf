// providing aws credentials 
provider "aws" {
  region  = "ap-south-1"
  profile = "BHUPESH"
}

// for using default value of vpc
 
data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

// for creating s3 bucket

resource "aws_s3_bucket" "task1-bucket-bs" {
  bucket = "task1-bucket-bs"
  acl    = "private"
   tags = {
    Name = "task1-bucket-bs"
  }
}
locals {
  s3_origin_id = "myS3Origin"
}




// for creating cloud front
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Some comment"
}


resource "aws_cloudfront_distribution" "task1_cloudfront" {

  origin {
    domain_name = aws_s3_bucket.task1-bucket-bs.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
  origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
}
  }


  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/content/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "task1_cloudfront"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.task1-bucket-bs.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }

}

resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = aws_s3_bucket.task1-bucket-bs.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

output "opdn"{
  value = aws_s3_bucket.task1-bucket-bs
}
output "opcd"{
  value = aws_cloudfront_distribution.task1_cloudfront
}
output "opcdn"{
  value = aws_cloudfront_distribution.task1_cloudfront.domain_name
}
