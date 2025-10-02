data "aws_region" "current" {}

resource "aws_api_gateway_rest_api" "this" {
  name = "${var.project_name}-${var.stage}-rest"
}

resource "aws_api_gateway_resource" "v1" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "v1"
}

resource "aws_api_gateway_resource" "list" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.v1.id
  path_part   = "list"
}

resource "aws_api_gateway_resource" "head" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.list.id
  path_part   = "head"
}

resource "aws_api_gateway_resource" "tail" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.list.id
  path_part   = "tail"
}

locals {
  methods = {
    head = aws_api_gateway_resource.head.id
    tail = aws_api_gateway_resource.tail.id
  }
}

# Create POST methods with API Key required
resource "aws_api_gateway_method" "post" {
  for_each         = local.methods
  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = each.value
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "lambda" {
  for_each                = aws_api_gateway_method.post
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = each.value.resource_id
  http_method             = each.value.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_arn
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  triggers = {
    redeploy = timestamp()
  }
  depends_on = [aws_api_gateway_integration.lambda]
}

resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = var.stage

  method_settings {
    metrics_enabled        = true
    logging_level          = "INFO"
    data_trace_enabled     = false
    resource_path          = "/*/*"
    http_method            = "*"
    throttling_burst_limit = 50
    throttling_rate_limit  = 25
  }

  # Per-method throttling
  method_settings {
    metrics_enabled        = true
    logging_level          = "INFO"
    data_trace_enabled     = false
    resource_path          = "/v1/list/head"
    http_method            = "POST"
    throttling_burst_limit = var.head_burst_limit
    throttling_rate_limit  = var.head_rate_limit
  }

  method_settings {
    metrics_enabled        = true
    logging_level          = "INFO"
    data_trace_enabled     = false
    resource_path          = "/v1/list/tail"
    http_method            = "POST"
    throttling_burst_limit = var.tail_burst_limit
    throttling_rate_limit  = var.tail_rate_limit
  }
}


# API Key + Usage Plan
resource "random_id" "key" {
  byte_length = 8
}

resource "aws_api_gateway_api_key" "this" {
  name    = "${var.project_name}-${var.stage}-key"
  value   = var.api_key_value != "" ? var.api_key_value : random_id.key.hex
  enabled = true
}

resource "aws_api_gateway_usage_plan" "this" {
  name = "${var.project_name}-${var.stage}-plan"

  throttle {
    burst_limit = 50
    rate_limit  = 25
  }

  api_stages {
    api_id = aws_api_gateway_rest_api.this.id
    stage  = aws_api_gateway_stage.this.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "this" {
  key_id        = aws_api_gateway_api_key.this.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.this.id
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

output "rest_invoke_url" {
  value = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.stage}"
}

output "rest_api_id" {
  value = aws_api_gateway_rest_api.this.id
}

output "api_key_value" {
  value     = aws_api_gateway_api_key.this.value
  sensitive = true
}


# Optional WAF association for REST API stage
resource "aws_wafv2_web_acl_association" "rest_assoc" {
  count        = var.enable_waf && length(var.waf_web_acl_arn) > 0 ? 1 : 0
  resource_arn = aws_api_gateway_stage.this.arn
  web_acl_arn  = var.waf_web_acl_arn
}
