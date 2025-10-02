output "api_endpoint" {
  value = module.http_api.invoke_url
}

output "lambda_name" {
  value = module.lambda.function_name
}


output "api_stage_arn" {
  value = module.http_api.stage_arn
}


# If REST API v1 module is enabled, expose its endpoint & API key
# Commented out since rest_api module is not currently enabled in main.tf
# output "rest_api_endpoint" {
#   value       = try(module.rest_api.rest_invoke_url, null)
#   description = "REST API v1 endpoint if rest_api module is used"
# }

# output "api_key_value" {
#   value     = try(module.rest_api.api_key_value, null)
#   sensitive = true
# }
