terraform {
  required_version = "~> 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.10.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Optional: default tags on all resources
  default_tags {
    tags = {
      Project     = "captcha-demo"
      Environment = var.env_name
      ManagedBy   = "Terraform"
    }
  }
}
