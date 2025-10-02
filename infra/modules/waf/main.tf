resource "aws_wafv2_ip_set" "allowlist" {
  count              = length(var.allowlist_cidrs) > 0 ? 1 : 0
  name               = "${var.project_name}-${var.stage}-allowlist"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.allowlist_cidrs
}

resource "aws_wafv2_web_acl" "this" {
  name  = "${var.project_name}-${var.stage}-waf"
  scope = "REGIONAL"

  dynamic "default_action" {
    for_each = var.enforce_allowlist ? [] : [1]
    content {
      allow {}
    }
  }

  dynamic "default_action" {
    for_each = var.enforce_allowlist ? [1] : []
    content {
      block {}
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-${var.stage}-waf"
    sampled_requests_enabled   = true
  }

  dynamic "rule" {
    for_each = var.enable_bot_control ? [1] : []
    content {
      name     = "AWS-AWSManagedRulesBotControlRuleSet"
      priority = 3
      statement {
        managed_rule_group_statement {
          name        = "AWSManagedRulesBotControlRuleSet"
          vendor_name = "AWS"
        }
      }
      override_action {
        none {}
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "BotControl"
        sampled_requests_enabled   = true
      }
    }
  }
  dynamic "rule" {
    for_each = length(var.allowlist_cidrs) > 0 ? [1] : []
    content {
      name     = "AllowKnownIPs"
      priority = 0
      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.allowlist[0].arn
        }
      }
      action {
        allow {}
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "AllowKnownIPs"
        sampled_requests_enabled   = true
      }
    }
  }
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    override_action {
      none {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    override_action {
      none {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "KnownBadInputs"
      sampled_requests_enabled   = true
    }
  }
}

# Delay to ensure API Gateway stage ARN is fully propagated across AWS services
# WAF needs time to recognize the stage resource after it's created
resource "time_sleep" "wait_for_api_stage" {
  create_duration = "60s"
  
  # Trigger the wait whenever the resource_arn (stage ARN) changes
  triggers = {
    stage_arn = var.resource_arn
  }
  
  depends_on = [aws_wafv2_web_acl.this]
}

resource "aws_wafv2_web_acl_association" "assoc" {
  resource_arn = var.resource_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
  
  depends_on = [time_sleep.wait_for_api_stage]
}


resource "aws_wafv2_rule_group" "bot_control_placeholder" {
  count    = 0 # Placeholder to keep structure simple
  capacity = 1
  name     = "${var.project_name}-${var.stage}-placeholder"
  scope    = "REGIONAL"
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "placeholder"
    sampled_requests_enabled   = true
  }
}

# WAF Logging Configuration - disabled by default
# To enable: set count = var.enable_logging ? 1 : 0 and provide log_destination_arns
# resource "aws_wafv2_web_acl_logging_configuration" "logging" {
#   count                   = 0
#   log_destination_configs = var.log_destination_arns
#   resource_arn            = aws_wafv2_web_acl.this.arn
# }
