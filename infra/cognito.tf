# Optional Cognito resources for JWT authorizer
variable "enable_cognito" {
  type    = bool
  default = false
}

variable "cognito_app_client_generate_secret" {
  type    = bool
  default = false
}

resource "aws_cognito_user_pool" "this" {
  count = var.enable_cognito ? 1 : 0
  name  = "${var.project_name}-${var.stage}-pool"
}

resource "aws_cognito_user_pool_client" "this" {
  count                                = var.enable_cognito ? 1 : 0
  name                                 = "${var.project_name}-${var.stage}-app"
  user_pool_id                         = aws_cognito_user_pool.this[0].id
  generate_secret                      = var.cognito_app_client_generate_secret
  prevent_user_existence_errors        = "ENABLED"
  allowed_oauth_flows_user_pool_client = false
}

# Convenience outputs for API authorizer config
output "jwt_issuer" {
  value = var.enable_cognito ? "https://cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.this[0].id}" : ""
}

output "jwt_audience" {
  value = var.enable_cognito ? [aws_cognito_user_pool_client.this[0].id] : []
}
