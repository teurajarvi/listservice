variable "project_name" { type = string }
variable "stage" { type = string }
variable "resource_arn" { type = string } # API Gateway Stage ARN


variable "allowlist_cidrs" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks (IPv4) to allow. Used when enforce_allowlist=true."
}

variable "enforce_allowlist" {
  type        = bool
  default     = false
  description = "If true, default action is BLOCK and only allowlist IPs are allowed."
}

variable "enable_bot_control" {
  type        = bool
  default     = false
  description = "Enable AWSManagedRulesBotControlRuleSet (may incur additional cost)."
}


# Optional logging destinations (WAFv2 supports Kinesis Data Firehose and CloudWatch Logs)
variable "enable_logging" {
  type        = bool
  default     = false
  description = "Enable WAFv2 logging (provide log_destination_arns)."
}

variable "log_destination_arns" {
  type        = list(string)
  default     = []
  description = "List of destination ARNs for WAF logging (e.g., Kinesis Data Firehose delivery stream ARN, or CloudWatch Logs group ARN in supported regions)."
}
