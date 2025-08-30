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

env_name             = "staging"
app_name             = "staging-captcha-demo"
cert_arn             = "arn:aws:acm:us-east-1:883585999409:certificate/f5fc69c6-4b8c-441a-97b0-365996afbd8c"
image_url            = "883585999409.dkr.ecr.us-east-1.amazonaws.com/app47/captcha-demo:latest"
zone_id              = "Z02768172R6QFAJA6KWK9"
fqdn_name            = "captcha-demo.app47.net"
rails_master_key_arn = "arn:aws:ssm:us-east-1:883585999409:parameter/captcha-demo/staging/rails_master_key"