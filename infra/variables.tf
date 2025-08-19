variable "aws_region" { default = "us-east-1" }
variable "vpc_id" { default = "vpc-80991be5" }
variable "alb_subnet_ids" { type = list(string) }
variable "ecs_subnet_ids" { type = list(string) }
variable "cert_arn" {}
variable "container_port" { default = 3000 }
variable "image_url" {}
variable "app_name" { default = "captcha-demo" }
variable "desired_count" { default = 1 }
variable "env_vars" {
  type = map(string)
  default = {
    RAILS_ENV       = "production"
    RACK_ENV        = "production"
    SECRET_KEY_BASE = "5d0e55548d89eba4a9c9edb73f1087af"
  }
}
variable "zone_id" {
  description = "Route 53 hosted zone ID for app47.net"
}

variable "app_role_name" {
  description = "IAM role name used by the application"
  type        = string
}
