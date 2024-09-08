locals {
  bucket_name = "${var.bucket_name}-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}


resource "aws_s3_bucket" "website_bucket" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_public_access_block" "origin_s3_acl" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# resource "aws_s3_bucket_website_configuration" "website_bucket" {
#   bucket = aws_s3_bucket.website_bucket.id

#   index_document {
#     suffix = var.index_document
#   }

#   error_document {
#     key = var.error_document
#   }
# }

resource "aws_s3_bucket_policy" "website_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website_bucket.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cdn.arn]
    }
  
  }
}

