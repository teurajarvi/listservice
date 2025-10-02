output "rest_invoke_url" { value = aws_api_gateway_rest_api.this.execution_arn }


output "stage_arn" { value = aws_api_gateway_stage.this.arn }
