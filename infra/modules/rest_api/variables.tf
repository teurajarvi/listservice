variable "project_name" {
  type = string
}

variable "stage" {
  type = string
}

variable "lambda_arn" {
  type = string
}

variable "function_name" {
  type = string
}

variable "api_key_value" {
  type        = string
  default     = ""
  description = "Optional API key value; if empty, random will be generated"
}

variable "head_burst_limit" {
  type    = number
  default = 50
}

variable "head_rate_limit" {
  type    = number
  default = 25
}

variable "tail_burst_limit" {
  type    = number
  default = 50
}

variable "tail_rate_limit" {
  type    = number
  default = 25
}

variable "enable_waf" {
  type        = bool
  default     = false
  description = "Enable WAF association for REST API stage"
}

variable "waf_web_acl_arn" {
  type        = string
  default     = ""
  description = "WAF WebACL ARN to associate with REST API stage"
}
