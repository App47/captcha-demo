resource "aws_cloudwatch_log_group" "captcha_demo" {
  name              = local.log_group_name
  retention_in_days = 7
}