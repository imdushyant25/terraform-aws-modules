# examples/lambda/main.tf
# Simple test configuration for the Lambda module

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}

# Simple Lambda function test
module "test_lambda" {
  source = "../../modules/lambda"
  
  function_name = "hello-world"
  runtime       = "python3.11"
  handler       = "lambda_function.lambda_handler"
  
  # Deploy from local source code
  source_code_path = "./src"
  
  environment = "dev"
  team        = "platform-team"
  
  # Basic configuration
  timeout     = 30
  memory_size = 128
  
  # Environment variables
  environment_variables = {
    LOG_LEVEL = "INFO"
    STAGE     = "development"
  }
  
  tags = {
    Project = "Lambda Module Test"
    Purpose = "Testing"
  }
}

# Outputs
output "function_name" {
  description = "Name of the Lambda function"
  value       = module.test_lambda.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = module.test_lambda.function_arn
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = module.test_lambda.log_group_name
}