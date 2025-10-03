module "lambda" {
  source              = "./modules/lambda"
  project_name        = var.project_name
  stage               = var.stage
  lambda_package_path = var.lambda_package_path
  log_level           = var.log_level
  enable_xray         = var.enable_xray
}

module "http_api" {
  source            = "./modules/http_api"
  project_name      = var.project_name
  stage             = var.stage
  lambda_invoke_arn = module.lambda.invoke_arn
  function_name     = module.lambda.function_name
}


# WAF is NOT supported with HTTP API v2 (ApiGatewayV2)
# WAFv2 only supports: REST API v1, ALB, AppSync, CloudFront
# To use WAF, either:
#   1. Switch to REST API v1 (uncomment module.rest_api below)
#   2. Add CloudFront in front of HTTP API and attach WAF to CloudFront
# module "waf" {
#   source       = "./modules/waf"
#   project_name = var.project_name
#   stage        = var.stage
#   resource_arn = module.http_api.stage_arn
#   depends_on   = [module.http_api]
# }

# Local helper to get stage ARN from module.http_api (via a data source)
data "aws_apigatewayv2_apis" "all" {}


module "alarms" {
  source               = "./modules/alarms"
  project_name         = var.project_name
  stage                = var.stage
  api_id               = module.http_api.api_id
  lambda_function_name = module.lambda.function_name
  # Optionally set: -var "alarm_email=you@example.com"
  alarm_email = var.alarm_email
}

# CloudWatch Dashboard for monitoring
module "dashboard" {
  source               = "./modules/dashboard"
  project_name         = var.project_name
  stage                = var.stage
  region               = var.region
  lambda_function_name = module.lambda.function_name
  api_id               = module.http_api.api_id
}

# Secrets Manager for API keys and sensitive data
module "secrets" {
  source       = "./modules/secrets"
  project_name = var.project_name
  stage        = var.stage
}


# Optional REST API v1 with API Keys + Usage Plan
# module "rest_api" {
#   source         = "./modules/rest_api"
#   project_name   = var.project_name
#   stage          = var.stage
#   lambda_arn     = module.lambda.invoke_arn
#   function_name  = module.lambda.function_name
#   head_burst_limit = 20
#   head_rate_limit  = 10
#   tail_burst_limit = 100
#   tail_rate_limit  = 50
#   enable_waf = true
# }


# If enabling REST API v1 and WAF, associate WebACL to the REST stage
# (Uncomment when module.rest_api is enabled.)
# module "waf_rest" {
#   source       = "./modules/waf"
#   project_name = var.project_name
#   stage        = var.stage
#   resource_arn = module.rest_api.stage_arn
# }
