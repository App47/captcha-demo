terraform {
  backend "s3" {
    bucket         = "app47terraform"
    key            = "ecs/captcha-demo/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
