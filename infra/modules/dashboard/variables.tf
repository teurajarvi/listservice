variable "project_name" {
  type        = string
  description = "Project name"
}

variable "stage" {
  type        = string
  description = "Environment stage (dev/stage/prod)"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "lambda_function_name" {
  type        = string
  description = "Lambda function name to monitor"
}

variable "api_id" {
  type        = string
  description = "API Gateway ID to monitor"
}
