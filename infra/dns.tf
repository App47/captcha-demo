

# Route 53 entry
resource "aws_route53_record" "cdn_dns" {
  zone_id = var.route53_zone_id
  name    = "captcha-demo.app47.net"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}


