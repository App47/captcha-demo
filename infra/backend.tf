# Use a backend to keep state

terraform {
  backend "s3" {
    bucket         = "app47terraform"
    key            = "envs/demo/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
