# Terraform (HCL)
app_role_name = "captcha_api_lambda_exec_role" # replace with your app's IAM role name

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

cert_arn = "arn:aws:acm:us-east-1:883585999409:certificate/f5fc69c6-4b8c-441a-97b0-365996afbd8c"

image_url = "883585999409.dkr.ecr.us-east-1.amazonaws.com/app47/captcha-demo:latest"

zone_id = "Z02768172R6QFAJA6KWK9" # Replace with the actual Hosted Zone ID for app47.net

rails_master_key_arn = "arn:aws:ssm:us-east-1:883585999409:parameter/captcha-demo/rails_master_key"