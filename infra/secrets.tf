resource "aws_ssm_parameter" "secret_key_base" {
  name  = "/captcha-demo/secret_key_base"
  type  = "SecureString"
  value = var.env_vars["SECRET_KEY_BASE"]
  # key_id = "arn:aws:kms:us-east-1:<account-id>:key/<kms-key-id>" # optional CMK
}
