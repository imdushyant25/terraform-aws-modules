# templates/simple-lambda/infrastructure/main.tf
# Template: Simple Lambda Function
# Use Case: Basic serverless function for simple tasks

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Simple Lambda function
module "lambda_function" {
  source = "git::https://github.com/imdushyant25/terraform-aws-modules.git//modules/lambda"
  
  # CUSTOMIZE THESE VALUES FOR YOUR PROJECT
  function_name = var.function_name
  description   = var.function_description
  runtime       = var.runtime
  handler       = var.handler
  
  # Deploy from your source code
  source_code_path = var.source_code_path
  
  # Function configuration
  timeout     = var.timeout
  memory_size = var.memory_size
  
  # Environment variables for your function
  environment_variables = var.environment_variables
  
  # Additional AWS service permissions (customize as needed)
  additional_policies = var.additional_policies
  
  # Required: Team and environment info
  environment = var.environment
  team        = var.team_name
  
  # Project tags
  tags = merge(
    var.tags,
    {
      Template = "simple-lambda"
      Project  = var.project_name
      Owner    = var.team_email
    }
  )
}

# Optional: CloudWatch dashboard for monitoring
resource "aws_cloudwatch_dashboard" "lambda_dashboard" {
  count          = var.create_dashboard ? 1 : 0
  dashboard_name = "${var.function_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", module.lambda_function.function_name],
            [".", "Errors", ".", "."],
            [".", "Invocations", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Lambda Metrics"
          period  = 300
        }
      }
    ]
  })
}