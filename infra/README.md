# Captcha Demo - Terraform Infrastructure

This directory contains the Terraform configuration for deploying the infrastructure needed by the Captcha Demo App. It sets up:

- An S3 bucket for static website hosting
- A Lambda function to process form submissions
- An API Gateway to expose the Lambda function
- Required IAM roles and permissions

---

## 🧰 Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) (v1.0+ recommended)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- An AWS account with credentials configured

---

## 💻 Setup Instructions

### ✅ macOS

1. **Install Terraform**
   ```bash
   brew tap hashicorp/tap
   brew install hashicorp/tap/terraform
   ```

2. **Install AWS CLI**
   ```bash
   brew install awscli
   ```

3. **Configure AWS CLI**
   ```bash
   aws configure --profile terraform
   ```

---

### ✅ Ubuntu/Debian

1. **Install Terraform**
   ```bash
   sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
   curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
   echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
   sudo apt-get update && sudo apt-get install terraform
   ```

2. **Install AWS CLI**
   ```bash
   sudo apt install awscli
   ```

3. **Configure AWS CLI**
   ```bash
   aws configure --profile terraform
   ```

---

## 🚀 Usage

```bash
cd infra
terraform init
terraform apply 
```

To destroy the infrastructure:

```bash
terraform destroy 
```

---

## 📁 Terraform File Overview

| File            | Purpose |
|------------------|---------|
| `main.tf`        | Terraform provider setup |
| `variables.tf`   | Input variables for region and bucket name |
| `s3.tf`          | S3 bucket and public access policy |
| `lambda.tf`      | Lambda function definition and zip packaging |
| `iam.tf`         | IAM roles and policies for Lambda execution |
| `api_gateway.tf` | API Gateway HTTP API and Lambda integration |
| `outputs.tf`     | Displays URLs after deployment |

---

## 📚 Helpful Links

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform CLI Commands](https://developer.hashicorp.com/terraform/cli/commands)
- [AWS Lambda Docs](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html)
- [API Gateway HTTP API](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api.html)
- [S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)

---
