data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/submit.py"
  output_path = "${path.module}/lambda_payload.zip"
}

resource "aws_lambda_function" "captcha_handler" {
  function_name = "captchaDemoFormHandler"
  handler       = "submit.lambda_handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_exec.arn
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

resource "aws_lambda_permission" "apigw_allow" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.captcha_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.demo.execution_arn}/*/*"
}
