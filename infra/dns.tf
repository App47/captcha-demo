

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

# Route 53 entry
resource "aws_route53_record" "api_dns" {
  zone_id = var.route53_zone_id
  name    = "captcha-demo-api.app47.net"
  type    = "A"

   alias {
    name = aws_apigatewayv2_domain_name.custom_api_domain.domain_name_configuration[0].target_domain_name
    zone_id = aws_apigatewayv2_domain_name.custom_api_domain.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
