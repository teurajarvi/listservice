resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}-${var.stage}-lambda-exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Principal = { Service = "lambda.amazonaws.com" },
      Effect    = "Allow"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_logs" {
  name = "${var.project_name}-${var.stage}-logs"
  role = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        # Restrict to only this Lambda function's log group
        Resource = [
          "arn:aws:logs:*:*:log-group:/aws/lambda/${var.project_name}-${var.stage}-handler",
          "arn:aws:logs:*:*:log-group:/aws/lambda/${var.project_name}-${var.stage}-handler:*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ],
        # Restrict to only this project's SSM parameters
        Resource = "arn:aws:ssm:*:*:parameter/${var.project_name}/${var.stage}/*"
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        # Allow Lambda to read secrets for this project/stage
        Resource = "arn:aws:secretsmanager:*:*:secret:${var.project_name}-${var.stage}-*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.project_name}-${var.stage}-handler"
  retention_in_days = 14
}

resource "aws_lambda_function" "this" {
  function_name    = "${var.project_name}-${var.stage}-handler"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "src/handler.lambda_handler"
  runtime          = "python3.12"
  filename         = var.lambda_package_path
  source_code_hash = filebase64sha256(var.lambda_package_path)

  environment {
    variables = {
      LOG_LEVEL = var.log_level
      STAGE     = var.stage
    }
  }

  tracing_config {
    mode = var.enable_xray ? "Active" : "PassThrough"
  }

  depends_on = [aws_cloudwatch_log_group.lambda]
}

resource "aws_iam_role_policy_attachment" "xray_write" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}
