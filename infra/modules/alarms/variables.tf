variable "project_name" {
  type = string
}

variable "stage" {
  type = string
}

variable "api_id" {
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "alarm_email" {
  type    = string
  default = ""
}
