# modules/lambda/outputs.tf

# Lambda function outputs
output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.function.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.function.arn
}

output "invoke_arn" {
  description = "Invoke ARN of the Lambda function (for use with API Gateway)"
  value       = aws_lambda_function.function.invoke_arn
}

output "qualified_arn" {
  description = "Qualified ARN of the Lambda function"
  value       = aws_lambda_function.function.qualified_arn
}

output "version" {
  description = "Latest published version of the Lambda function"
  value       = aws_lambda_function.function.version
}

output "last_modified" {
  description = "Date the Lambda function was last modified"
  value       = aws_lambda_function.function.last_modified
}

output "source_code_hash" {
  description = "Base64-encoded representation of raw SHA-256 sum of the zip file"
  value       = aws_lambda_function.function.source_code_hash
}

output "source_code_size" {
  description = "Size in bytes of the function .zip file"
  value       = aws_lambda_function.function.source_code_size
}

# IAM role outputs
output "execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.arn
}

output "execution_role_name" {
  description = "Name of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.name
}

# CloudWatch outputs
output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_log_group.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_log_group.arn
}

# Runtime information
output "runtime" {
  description = "Runtime of the Lambda function"
  value       = aws_lambda_function.function.runtime
}

output "handler" {
  description = "Handler of the Lambda function"
  value       = aws_lambda_function.function.handler
}

output "timeout" {
  description = "Timeout of the Lambda function"
  value       = aws_lambda_function.function.timeout
}

output "memory_size" {
  description = "Memory size of the Lambda function"
  value       = aws_lambda_function.function.memory_size
}

# Computed values for use in other modules
output "function_url" {
  description = "Lambda function URL (if function URL is enabled separately)"
  value       = "https://lambda.${data.aws_region.current.name}.amazonaws.com/2015-03-31/functions/${aws_lambda_function.function.function_name}/invocations"
}

# Data source for current region
data "aws_region" "current" {}