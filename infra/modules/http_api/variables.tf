variable "project_name" { type = string }
variable "stage" { type = string }
variable "lambda_invoke_arn" { type = string }
variable "function_name" { type = string }


variable "enable_jwt" {
  type    = bool
  default = false
}

variable "jwt_issuer" {
  type        = string
  default     = ""
  description = "JWT issuer URL, e.g. https://cognito-idp.eu-north-1.amazonaws.com/<userPoolId>"
}

variable "jwt_audience" {
  type        = list(string)
  default     = []
  description = "JWT audience, e.g. [ \"<appClientId>\" ]"
}

variable "throttling_burst_limit" {
  type    = number
  default = 50
}

variable "throttling_rate_limit" {
  type    = number
  default = 25
}


variable "public_routes" {
  description = "List of routes that do not require JWT (e.g., [\"POST /v1/list/head\"])"
  type        = list(string)
  default     = []
}


variable "enable_apikey_authorizer" {
  type    = bool
  default = false
}

variable "authorizer_lambda_arn" {
  type    = string
  default = ""
}
