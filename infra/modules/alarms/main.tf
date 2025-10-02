resource "aws_sns_topic" "alarms" {
  name = "${var.project_name}-${var.stage}-alarms"
}

resource "aws_sns_topic_subscription" "email" {
  count     = length(var.alarm_email) > 0 ? 1 : 0
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# API Gateway v2 5XX errors
resource "aws_cloudwatch_metric_alarm" "api_5xx" {
  alarm_name          = "${var.project_name}-${var.stage}-api-5xx"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  dimensions = {
    ApiId = var.api_id
    Stage = var.stage
  }
  alarm_actions = [aws_sns_topic.alarms.arn]
}

# API Gateway v2 p95 Latency > 1000 ms
resource "aws_cloudwatch_metric_alarm" "api_latency_p95" {
  alarm_name          = "${var.project_name}-${var.stage}-api-latency-p95"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Latency"
  namespace           = "AWS/ApiGateway"
  period              = 300
  extended_statistic  = "p95"
  threshold           = 1000
  dimensions = {
    ApiId = var.api_id
    Stage = var.stage
  }
  alarm_actions = [aws_sns_topic.alarms.arn]
}

# Lambda Errors
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.project_name}-${var.stage}-lambda-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  dimensions = {
    FunctionName = var.lambda_function_name
  }
  alarm_actions = [aws_sns_topic.alarms.arn]
}
