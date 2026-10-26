# Issue a dedicated certificate in the same region as the shared ALB.
resource "aws_acm_certificate" "captcha_demo" {
  domain_name       = var.fqdn_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Keep these records for ACM renewal as well as initial validation.
resource "aws_route53_record" "captcha_demo_certificate_validation" {
  for_each = {
    for option in aws_acm_certificate.captcha_demo.domain_validation_options :
    option.domain_name => {
      name   = option.resource_record_name
      type   = option.resource_record_type
      record = option.resource_record_value
    }
  }

  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "captcha_demo" {
  certificate_arn = aws_acm_certificate.captcha_demo.arn
  validation_record_fqdns = [
    for record in aws_route53_record.captcha_demo_certificate_validation : record.fqdn
  ]
}

# Add an SNI certificate without changing the shared listener's default certificate.
resource "aws_lb_listener_certificate" "captcha_demo" {
  listener_arn    = var.alb_https_listener_arn
  certificate_arn = aws_acm_certificate_validation.captcha_demo.certificate_arn

  lifecycle {
    create_before_destroy = true
  }
}
