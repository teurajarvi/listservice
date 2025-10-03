resource "aws_iam_role" "auth_exec" {
  name = "${var.project_name}-${var.stage}-auth-exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow"
    }]
  })
}

resource "aws_iam_role_policy" "logs" {
  name = "${var.project_name}-${var.stage}-authorizer-logs"
  role = aws_iam_role.auth_exec.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      # Restrict to only this authorizer function's log group
      Resource = [
        "arn:aws:logs:*:*:log-group:/aws/lambda/${var.project_name}-${var.stage}-authorizer",
        "arn:aws:logs:*:*:log-group:/aws/lambda/${var.project_name}-${var.stage}-authorizer:*"
      ]
    }]
  })
}

resource "aws_cloudwatch_log_group" "auth" {
  name              = "/aws/lambda/${var.project_name}-${var.stage}-authorizer"
  retention_in_days = 14
}

data "archive_file" "auth_zip" {
  type = "zip"
  source {
    content  = <<PY
import os, json, logging

EXPECTED = os.environ.get("EXPECTED_API_KEY", "")

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    # HTTP API v2 request -> Lambda authorizer (REQUEST type)
    headers = (event.get("headers") or {})
    api_key = headers.get("x-api-key") or headers.get("X-API-Key")

    if api_key and EXPECTED and api_key == EXPECTED:
        return {
            "isAuthorized": True,
            "context": {"auth": "apikey"}
        }
    return {
        "isAuthorized": False,
        "context": {"reason": "invalid or missing x-api-key"}
    }
PY
    filename = "authorizer.py"
  }
  output_path = "${path.module}/auth.zip"
}

resource "aws_lambda_function" "auth" {
  function_name    = "${var.project_name}-${var.stage}-auth"
  role             = aws_iam_role.auth_exec.arn
  handler          = "authorizer.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.auth_zip.output_path
  source_code_hash = data.archive_file.auth_zip.output_base64sha256

  environment {
    variables = {
      EXPECTED_API_KEY = var.expected_api_key
    }
  }

  depends_on = [aws_cloudwatch_log_group.auth]
}

output "authorizer_arn" { value = aws_lambda_function.auth.arn }
output "authorizer_name" { value = aws_lambda_function.auth.function_name }
