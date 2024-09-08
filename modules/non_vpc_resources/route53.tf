data "aws_route53_zone" "kosa" {
  name            = "${var.domain_name}"
  private_zone    = false
}

# acm validation
resource "aws_route53_record" "cert_validation" {

  for_each = {
    for dvo in aws_acm_certificate.cdn.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
#   name          = aws_acm_certificate.cdn.domain_validation_options.resource_record_name
#   record        = aws_acm_certificate.cdn.domain_validation_options.resource_record_value
#   type          = aws_acm_certificate.cdn.domain_validation_options.resource_record_type

  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  allow_overwrite = true
  ttl = 60
  zone_id         = data.aws_route53_zone.kosa.id
}

# cloudfront alias1 (var.domain_name)
resource "aws_route53_record" "cloudfront_alias1" {
  name    = "test.${var.domain_name}"
  type    = "A"
  # zone_id = aws_route53_zone.kosa.zone_id
  zone_id         = data.aws_route53_zone.kosa.id

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

# cloudfront alias2 (www.var.domain_name)
resource "aws_route53_record" "cloudfront_alias2" {
  name    = "www.test.${var.domain_name}"
  type    = "A"
  # zone_id = aws_route53_zone.kosa.zone_id
  zone_id         = data.aws_route53_zone.kosa.id

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}
