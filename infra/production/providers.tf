terraform {
  required_version = "= 1.13.1"

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
      Application = var.app_name
      Environment = var.env_name
      ManagedBy   = "Terraform"
    }
  }
}