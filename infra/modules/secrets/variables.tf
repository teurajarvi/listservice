variable "project_name" {
  type        = string
  description = "Project name"
}

variable "stage" {
  type        = string
  description = "Environment stage (dev/stage/prod)"
}

variable "recovery_window_in_days" {
  type        = number
  description = "Number of days to retain deleted secrets (0-30)"
  default     = 7
}

variable "enable_rotation" {
  type        = bool
  description = "Enable automatic secret rotation"
  default     = false
}

variable "rotation_lambda_arn" {
  type        = string
  description = "ARN of Lambda function for secret rotation"
  default     = ""
}
