# modules/lambda/main.tf

locals {
  # Standard naming convention
  function_name = "${var.function_name}-${var.environment}"
  
  # Merge organizational tags with user tags
  tags = merge(
    var.tags,
    {
      ManagedBy   = "Terraform"
      Environment = var.environment
      Team        = var.team
      Service     = "lambda"
    }
  )
  
  # Environment variables with encryption
  environment_variables = var.environment_variables != null ? {
    variables = var.environment_variables
  } : null
}

# Lambda execution role
resource "aws_iam_role" "lambda_execution_role" {
  name = "${local.function_name}-execution-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  
  tags = local.tags
}

# Basic Lambda execution policy (CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_execution_role.name
}

# VPC execution policy (if VPC configuration is provided)
resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
  count      = var.vpc_config != null ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.lambda_execution_role.name
}

# Custom policy for additional service permissions
resource "aws_iam_role_policy" "lambda_custom_policy" {
  count = length(var.additional_policies) > 0 ? 1 : 0
  
  name = "${local.function_name}-custom-policy"
  role = aws_iam_role.lambda_execution_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = var.additional_policies
  })
}

# Create deployment package if source_code_path is provided
data "archive_file" "lambda_zip" {
  count = var.source_code_path != null ? 1 : 0
  
  type        = "zip"
  source_dir  = var.source_code_path
  output_path = "${path.module}/tmp/${local.function_name}.zip"
}

# Lambda function
resource "aws_lambda_function" "function" {
  function_name = local.function_name
  description   = var.description
  
  # Runtime configuration
  runtime = var.runtime
  handler = var.handler
  timeout = var.timeout
  memory_size = var.memory_size
  
  # Execution configuration
  role = aws_iam_role.lambda_execution_role.arn
  
  # Code source - either from local path or S3
  filename         = var.source_code_path != null ? data.archive_file.lambda_zip[0].output_path : null
  source_code_hash = var.source_code_path != null ? data.archive_file.lambda_zip[0].output_base64sha256 : null
  
  # S3 source configuration
  s3_bucket         = var.s3_bucket
  s3_key           = var.s3_key
  s3_object_version = var.s3_object_version
  
  # Environment variables with KMS encryption
  dynamic "environment" {
    for_each = local.environment_variables != null ? [local.environment_variables] : []
    content {
      variables = environment.value.variables
    }
  }
  
  # KMS key for encryption
  kms_key_arn = var.kms_key_arn
  
  # VPC configuration
  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }
  
  # Layers
  layers = var.layer_arns
  
  # Dead letter queue
  dynamic "dead_letter_config" {
    for_each = var.dlq_target_arn != null ? [1] : []
    content {
      target_arn = var.dlq_target_arn
    }
  }
  
  # Reserved concurrency
  reserved_concurrent_executions = var.reserved_concurrent_executions
  
  # Tracing
  tracing_config {
    mode = var.enable_tracing ? "Active" : "PassThrough"
  }
  
  tags = local.tags
  
  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy_attachment.lambda_vpc_execution,
    aws_cloudwatch_log_group.lambda_log_group
  ]
}

# CloudWatch Log Group for Lambda function
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = var.log_retention_days
  kms_key_id       = var.log_kms_key_id
  
  tags = local.tags
}

# Lambda permission for API Gateway (if needed)
resource "aws_lambda_permission" "api_gateway" {
  count = var.allow_api_gateway ? 1 : 0
  
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "apigateway.amazonaws.com"
  
  # More specific source_arn can be provided via variable
  source_arn = var.api_gateway_source_arn != null ? var.api_gateway_source_arn : "*"
}

# Lambda permission for CloudWatch Events/EventBridge (if needed)
resource "aws_lambda_permission" "eventbridge" {
  count = var.allow_eventbridge ? 1 : 0
  
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "events.amazonaws.com"
  
  source_arn = var.eventbridge_rule_arn
}

# Lambda permission for S3 (if needed)
resource "aws_lambda_permission" "s3" {
  count = var.allow_s3 ? 1 : 0
  
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "s3.amazonaws.com"
  
  source_arn = var.s3_bucket_arn
}