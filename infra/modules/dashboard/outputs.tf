output "dashboard_name" {
  value       = aws_cloudwatch_dashboard.main.dashboard_name
  description = "Name of the CloudWatch dashboard"
}

output "dashboard_arn" {
  value       = aws_cloudwatch_dashboard.main.dashboard_arn
  description = "ARN of the CloudWatch dashboard"
}
