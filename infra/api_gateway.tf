resource "aws_apigatewayv2_api" "demo" {
  name          = "CaptchaDemo"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins     = ["https://captcha-demo.app47.net"]
    allow_methods     = ["GET", "POST", "OPTIONS"]
    allow_headers     = ["Content-Type"]
  }
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.demo.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.captcha_handler.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "submit_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /submit"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_domain_name" "custom_api_domain" {
  domain_name = "captcha-demo-api.app47.net"

  domain_name_configuration {
    certificate_arn = var.app47_net_acm_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "api_mapping" {
  api_id      = aws_apigatewayv2_api.api.id
  domain_name = aws_apigatewayv2_domain_name.custom_api_domain.domain_name
  stage       = aws_apigatewayv2_stage.default.name
}


