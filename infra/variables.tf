variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-north-1"
}

variable "project_name" {
  type    = string
  default = "listservice"
}

variable "stage" {
  type    = string
  default = "dev"
}

variable "lambda_package_path" {
  type        = string
  description = "Path to built lambda zip (e.g. ../build/listservice.zip)"
}

variable "log_level" {
  type    = string
  default = "INFO"
}

variable "enable_xray" {
  type    = bool
  default = false
}


variable "alarm_email" {
  type        = string
  description = "Email for CloudWatch alarm notifications (optional)"
  default     = ""
}
