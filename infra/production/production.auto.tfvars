# Terraform (HCL)
vpc_id = "vpc-80991be5"

alb_subnet_ids = [
  "subnet-adbe1be5",
  "subnet-a032c1fd",
  "subnet-a1e10a8d"
]

ecs_subnet_ids = [
  "subnet-ccf350bb",
  "subnet-ce14d697",
  "subnet-8f2ed0a0"
]

env_name             = "production"
app_name             = "production-captcha-demo"
cert_arn             = "arn:aws:acm:us-east-1:883585999409:certificate/65a1cd6d-269e-4553-b7e1-944240f52cdd"
zone_id              = "Z07160984GV0SLEISVV6"
fqdn_name            = "captcha-demo.app47.com"
rails_master_key_arn = "arn:aws:ssm:us-east-1:883585999409:parameter/captcha-demo/production/rails_master_key"

alb_https_listener_arn = "arn:aws:elasticloadbalancing:us-east-1:883585999409:listener/app/shared/32f3a57cd7684540/0cf3b168b8ae2d58"
alb_security_group_id  = "sg-0dcfe0bea8517d329"
alb_dns_name           = "shared-555384845.us-east-1.elb.amazonaws.com"
alb_dns_zone_id        = "Z35SXDOTRQ7X7K"
