# templates/simple-lambda/infrastructure/outputs.tf
# Outputs for Simple Lambda Template

output "function_name" {
  description = "Name of the deployed Lambda function"
  value       = module.lambda_function.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda_function.function_arn
}

output "invoke_arn" {
  description = "Invoke ARN (for API Gateway integration)"
  value       = module.lambda_function.invoke_arn
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = module.lambda_function.log_group_name
}

output "execution_role_arn" {
  description = "Lambda execution role ARN"
  value       = module.lambda_function.execution_role_arn
}

output "dashboard_url" {
  description = "CloudWatch dashboard URL"
  value = var.create_dashboard ? "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${var.function_name}-${var.environment}-dashboard" : null
}

# Helpful information for teams
output "next_steps" {
  description = "What to do next"
  value = {
    test_function = "aws lambda invoke --function-name ${module.lambda_function.function_name} --payload '{}' response.json"
    view_logs     = "aws logs tail ${module.lambda_function.log_group_name} --follow"
    dashboard     = var.create_dashboard ? "Check your CloudWatch dashboard for metrics" : "Set create_dashboard = true for monitoring"
  }
}