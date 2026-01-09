resource "aws_route53_record" "captcha_demo" {
  zone_id = var.zone_id # You'll define this in variables.tf or .tfvars
  name    = var.fqdn_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_dns_zone_id
    evaluate_target_health = false
  }
}
