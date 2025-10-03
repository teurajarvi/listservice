resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.stage}"

  dashboard_body = jsonencode({
    widgets = [
      # Lambda Invocations
      {
        type = "metric"
        x    = 0
        y    = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", { stat = "Sum", label = "Total Invocations" }],
            [".", "Errors", { stat = "Sum", label = "Errors", yAxis = "right" }],
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.region
          title   = "Lambda Invocations & Errors"
          period  = 300
          dimensions = {
            FunctionName = var.lambda_function_name
          }
        }
      },
      
      # Lambda Duration
      {
        type = "metric"
        x    = 12
        y    = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Duration", { stat = "Average", label = "Avg Duration" }],
            ["...", { stat = "Maximum", label = "Max Duration" }],
            ["...", { stat = "Minimum", label = "Min Duration" }],
          ]
          view   = "timeSeries"
          region = var.region
          title  = "Lambda Duration (ms)"
          period = 300
          yAxis = {
            left = {
              min = 0
            }
          }
          dimensions = {
            FunctionName = var.lambda_function_name
          }
        }
      },
      
      # Lambda Concurrent Executions
      {
        type = "metric"
        x    = 0
        y    = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "ConcurrentExecutions", { stat = "Maximum" }],
          ]
          view   = "timeSeries"
          region = var.region
          title  = "Lambda Concurrent Executions"
          period = 60
          dimensions = {
            FunctionName = var.lambda_function_name
          }
        }
      },
      
      # Lambda Throttles
      {
        type = "metric"
        x    = 12
        y    = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Throttles", { stat = "Sum" }],
          ]
          view   = "timeSeries"
          region = var.region
          title  = "Lambda Throttles"
          period = 300
          annotations = {
            horizontal = [
              {
                value = 0
                label = "No Throttles"
                fill  = "below"
              }
            ]
          }
          dimensions = {
            FunctionName = var.lambda_function_name
          }
        }
      },
      
      # API Gateway Requests
      {
        type = "metric"
        x    = 0
        y    = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApiGateway", "Count", { stat = "Sum", label = "Total Requests" }],
            [".", "4XXError", { stat = "Sum", label = "4XX Errors" }],
            [".", "5XXError", { stat = "Sum", label = "5XX Errors" }],
          ]
          view   = "timeSeries"
          region = var.region
          title  = "API Gateway Requests & Errors"
          period = 300
          dimensions = {
            ApiId = var.api_id
          }
        }
      },
      
      # API Gateway Latency
      {
        type = "metric"
        x    = 12
        y    = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApiGateway", "Latency", { stat = "Average", label = "Avg Latency" }],
            ["...", { stat = "p99", label = "p99 Latency" }],
          ]
          view   = "timeSeries"
          region = var.region
          title  = "API Gateway Latency (ms)"
          period = 300
          dimensions = {
            ApiId = var.api_id
          }
        }
      },
      
      # Error Rate Percentage
      {
        type = "metric"
        x    = 0
        y    = 18
        width  = 24
        height = 6
        properties = {
          metrics = [
            [
              {
                expression = "(m2 / m1) * 100"
                label      = "Error Rate %"
                id         = "e1"
                yAxis      = "left"
              }
            ],
            [
              "AWS/Lambda",
              "Invocations",
              "FunctionName",
              var.lambda_function_name,
              {
                id      = "m1"
                stat    = "Sum"
                visible = false
              }
            ],
            [
              "AWS/Lambda",
              "Errors",
              "FunctionName",
              var.lambda_function_name,
              {
                id      = "m2"
                stat    = "Sum"
                visible = false
              }
            ]
          ]
          view   = "timeSeries"
          region = var.region
          title  = "Lambda Error Rate %"
          period = 300
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
          annotations = {
            horizontal = [
              {
                value = 5
                label = "5% Error Threshold"
                fill  = "above"
                color = "#d13212"
              }
            ]
          }
        }
      },
      
      # Summary Statistics
      {
        type = "metric"
        x    = 0
        y    = 24
        width  = 24
        height = 3
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", { stat = "Sum", label = "Total Invocations" }],
            [".", "Errors", { stat = "Sum", label = "Total Errors" }],
            [".", "Throttles", { stat = "Sum", label = "Total Throttles" }],
            [".", "Duration", { stat = "Average", label = "Avg Duration (ms)" }],
          ]
          view   = "singleValue"
          region = var.region
          title  = "Summary Statistics (Last Hour)"
          period = 3600
          dimensions = {
            FunctionName = var.lambda_function_name
          }
        }
      }
    ]
  })
}
