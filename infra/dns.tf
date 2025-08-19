resource "aws_route53_record" "captcha_demo" {
  zone_id = var.zone_id # You'll define this in variables.tf or .tfvars
  name    = "captcha-demo.app47.net"
  type    = "A"

  alias {
    name                   = aws_lb.captcha_demo.dns_name
    zone_id                = aws_lb.captcha_demo.zone_id
    evaluate_target_health = false
  }
}
