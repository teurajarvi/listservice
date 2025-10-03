resource "random_password" "api_key" {
  length  = 32
  special = true
}

resource "aws_secretsmanager_secret" "api_key" {
  name                    = "${var.project_name}-${var.stage}-api-key"
  description             = "API Key for ${var.project_name} ${var.stage} environment"
  recovery_window_in_days = var.recovery_window_in_days

  tags = {
    Project     = var.project_name
    Environment = var.stage
    ManagedBy   = "Terraform"
  }
}

resource "aws_secretsmanager_secret_version" "api_key" {
  secret_id     = aws_secretsmanager_secret.api_key.id
  secret_string = jsonencode({
    api_key    = random_password.api_key.result
    created_at = timestamp()
    environment = var.stage
  })
}

# Optional: Enable automatic rotation (requires Lambda function)
# resource "aws_secretsmanager_secret_rotation" "api_key" {
#   count               = var.enable_rotation ? 1 : 0
#   secret_id           = aws_secretsmanager_secret.api_key.id
#   rotation_lambda_arn = var.rotation_lambda_arn
#
#   rotation_rules {
#     automatically_after_days = 30
#   }
# }
