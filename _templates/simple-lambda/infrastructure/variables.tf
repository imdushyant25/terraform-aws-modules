# templates/simple-lambda/infrastructure/variables.tf
# Variables for Simple Lambda Template

# Required variables - teams must provide these
variable "function_name" {
  description = "Name of your Lambda function (will be prefixed with environment)"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.function_name))
    error_message = "Function name must contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "team_name" {
  description = "Your team name (e.g., 'backend-team', 'data-team')"
  type        = string
}

variable "project_name" {
  description = "Your project name"
  type        = string
}

variable "team_email" {
  description = "Team contact email"
  type        = string
}

# Function configuration with sensible defaults
variable "function_description" {
  description = "Description of your Lambda function"
  type        = string
  default     = "Lambda function deployed via service catalog"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.11"
  
  validation {
    condition = contains([
      "python3.8", "python3.9", "python3.10", "python3.11",
      "nodejs16.x", "nodejs18.x", "nodejs20.x",
      "java11", "java17", "java21"
    ], var.runtime)
    error_message = "Runtime must be one of the supported Lambda runtimes."
  }
}

variable "handler" {
  description = "Lambda function handler"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "source_code_path" {
  description = "Path to your source code directory"
  type        = string
  default     = "../src"
}

variable "timeout" {
  description = "Function timeout in seconds"
  type        = number
  default     = 30
  
  validation {
    condition     = var.timeout >= 1 && var.timeout <= 900
    error_message = "Timeout must be between 1 and 900 seconds."
  }
}

variable "memory_size" {
  description = "Function memory in MB"
  type        = number
  default     = 128
  
  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "Memory must be between 128 and 10240 MB."
  }
}

# Environment and deployment settings
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "develop", "test", "staging", "stage", "prod", "production"], var.environment)
    error_message = "Environment must be one of: dev, develop, test, staging, stage, prod, production."
  }
}

# Optional configuration
variable "environment_variables" {
  description = "Environment variables for your Lambda function"
  type        = map(string)
  default = {
    LOG_LEVEL = "INFO"
  }
}

variable "additional_policies" {
  description = "Additional IAM policies for your Lambda function"
  type = list(object({
    Effect   = string
    Action   = list(string)
    Resource = list(string)
  }))
  default = []
}

variable "tags" {
  description = "Additional tags for your resources"
  type        = map(string)
  default     = {}
}

variable "create_dashboard" {
  description = "Create CloudWatch dashboard for monitoring"
  type        = bool
  default     = true
}