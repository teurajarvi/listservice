output "secret_arn" {
  value       = aws_secretsmanager_secret.api_key.arn
  description = "ARN of the API key secret"
}

output "secret_name" {
  value       = aws_secretsmanager_secret.api_key.name
  description = "Name of the API key secret"
}

output "api_key_value" {
  value       = random_password.api_key.result
  description = "The API key value (sensitive)"
  sensitive   = true
}
