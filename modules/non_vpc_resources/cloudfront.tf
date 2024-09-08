# OAC
resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "S3-OAC-2"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cdn" {
  provider = aws.virginia
  
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
    origin_id   = "S3-website"
  }
  aliases             = ["test.${var.domain_name}", "www.test.${var.domain_name}"]
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "S3 CloudFront distribution"
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = "S3-website"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cdn.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }
  
  web_acl_id = aws_wafv2_web_acl.cdn.arn

  depends_on = [ 
    aws_acm_certificate_validation.cdn
   ]
}