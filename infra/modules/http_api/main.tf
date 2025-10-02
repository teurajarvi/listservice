resource "aws_apigatewayv2_api" "http" {
  name          = "${var.project_name}-${var.stage}-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.http.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = var.lambda_invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_authorizer" "lambda_request" {
  count                             = var.enable_apikey_authorizer ? 1 : 0
  api_id                            = aws_apigatewayv2_api.http.id
  name                              = "${var.project_name}-${var.stage}-apikey"
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = var.authorizer_lambda_arn
  identity_sources                  = ["$request.header.x-api-key"]
  authorizer_payload_format_version = "2.0"
  enable_simple_responses           = true
}

resource "aws_apigatewayv2_authorizer" "jwt" {

  count            = var.enable_jwt ? 1 : 0
  api_id           = aws_apigatewayv2_api.http.id
  name             = "${var.project_name}-${var.stage}-jwt"
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  jwt_configuration {
    audience = var.jwt_audience
    issuer   = var.jwt_issuer
  }
}

resource "aws_apigatewayv2_route" "head" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "POST /v1/list/head"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"

  # If enable_jwt and route not in public_routes => require JWT
  authorization_type = var.enable_jwt && !(contains(var.public_routes, "POST /v1/list/head")) ? "JWT" : (var.enable_apikey_authorizer ? "CUSTOM" : null)
  authorizer_id      = var.enable_jwt && !(contains(var.public_routes, "POST /v1/list/head")) ? aws_apigatewayv2_authorizer.jwt[0].id : (var.enable_apikey_authorizer ? aws_apigatewayv2_authorizer.lambda_request[0].id : null)
}


resource "aws_apigatewayv2_route" "tail" {
  api_id    = aws_apigatewayv2_api.http.id
  route_key = "POST /v1/list/tail"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"

  # If enable_jwt and route not in public_routes => require JWT
  authorization_type = var.enable_jwt && !(contains(var.public_routes, "POST /v1/list/tail")) ? "JWT" : (var.enable_apikey_authorizer ? "CUSTOM" : null)
  authorizer_id      = var.enable_jwt && !(contains(var.public_routes, "POST /v1/list/tail")) ? aws_apigatewayv2_authorizer.jwt[0].id : (var.enable_apikey_authorizer ? aws_apigatewayv2_authorizer.lambda_request[0].id : null)
}


resource "aws_apigatewayv2_stage" "stage" {
  default_route_settings {
    throttling_burst_limit = var.throttling_burst_limit
    throttling_rate_limit  = var.throttling_rate_limit
  }

  api_id      = aws_apigatewayv2_api.http.id
  name        = var.stage
  auto_deploy = true
}

resource "aws_lambda_permission" "api_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}
