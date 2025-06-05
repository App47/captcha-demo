variable "bucket_name" {
  description = "S3 Bucket to host the demo web site"
  type        = string
  default     = "app47captchademo"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "route53_zone_id" {
  description = "The Route53 zone ID for app47.net"
  type        = string
  default     = "Z02768172R6QFAJA6KWK9"
}

variable "app47_net_acm_arn" {
  description = "The ARN for the App47.net ACM certficate"
  type        = string
  default     = "arn:aws:acm:us-east-1:883585999409:certificate/f5fc69c6-4b8c-441a-97b0-365996afbd8c"
}
