terraform {
  backend "s3" {
    bucket       = "app47terraform"
    key          = "ecs/captcha-demo/production.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
