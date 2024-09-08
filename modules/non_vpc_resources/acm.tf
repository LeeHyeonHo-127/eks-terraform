resource "aws_acm_certificate" "cdn" {
  domain_name       = "test.${var.domain_name}"
  validation_method = "DNS"

  subject_alternative_names = ["*.test.${var.domain_name}"]

  lifecycle {
    create_before_destroy = true
  }

  provider = aws.virginia
}

resource "aws_acm_certificate_validation" "cdn" {
  certificate_arn         = aws_acm_certificate.cdn.arn
#   validation_record_fqdns = aws_route53_record.cert_validation.fqdn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
  provider = aws.virginia
}

