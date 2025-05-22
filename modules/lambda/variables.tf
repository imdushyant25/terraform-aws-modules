# modules/lambda/variables.tf

# Required variables
variable "function_name" {
  description = "Name of the Lambda function (environment will be appended)"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.function_name))
    error_message = "Function name must contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  
  validation {
    condition = contains([
      "python3.8", "python3.9", "python3.10", "python3.11",
      "nodejs16.x", "nodejs18.x", "nodejs20.x",
      "java11", "java17", "java21",
      "dotnet6", "dotnet8",
      "go1.x",
      "ruby3.2"
    ], var.runtime)
    error_message = "Runtime must be one of the supported Lambda runtimes."
  }
}

variable "handler" {
  description = "Entry point for the Lambda function"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  
  validation {
    condition     = can(regex("^(dev|develop|test|staging|stage|prod|production)$", var.environment))
    error_message = "Environment must be one of: dev, develop, test, staging, stage, prod, production."
  }
}

variable "team" {
  description = "Team responsible for this Lambda function"
  type        = string
}

# Code source configuration (either local path OR S3)
variable "source_code_path" {
  description = "Path to the source code directory (alternative to S3 deployment)"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket containing the deployment package"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 key of the deployment package"
  type        = string
  default     = null
}

variable "s3_object_version" {
  description = "S3 object version of the deployment package"
  type        = string
  default     = null
}

# Optional configuration
variable "description" {
  description = "Description of the Lambda function"
  type        = string
  default     = "Lambda function managed by Terraform"
}

variable "timeout" {
  description = "Timeout for the Lambda function in seconds"
  type        = number
  default     = 30
  
  validation {
    condition     = var.timeout >= 1 && var.timeout <= 900
    error_message = "Timeout must be between 1 and 900 seconds."
  }
}

variable "memory_size" {
  description = "Memory size for the Lambda function in MB"
  type        = number
  default     = 128
  
  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "Memory size must be between 128 MB and 10,240 MB."
  }
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = null
}

variable "kms_key_arn" {
  description = "KMS key ARN for encrypting environment variables"
  type        = string
  default     = null
}

# VPC configuration
variable "vpc_config" {
  description = "VPC configuration for the Lambda function"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

# Layer configuration
variable "layer_arns" {
  description = "List of Lambda layer ARNs to attach to the function"
  type        = list(string)
  default     = []
  
  validation {
    condition     = length(var.layer_arns) <= 5
    error_message = "Lambda functions can have at most 5 layers."
  }
}

# Dead letter queue configuration
variable "dlq_target_arn" {
  description = "ARN of SQS queue or SNS topic for dead letter queue"
  type        = string
  default     = null
}

# Concurrency configuration
variable "reserved_concurrent_executions" {
  description = "Reserved concurrent executions for the Lambda function"
  type        = number
  default     = null
  
  validation {
    condition     = var.reserved_concurrent_executions == null ? true : var.reserved_concurrent_executions >= 0
    error_message = "Reserved concurrent executions must be 0 or greater."
  }
}

# Monitoring and logging
variable "enable_tracing" {
  description = "Enable AWS X-Ray tracing"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 14
  
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.log_retention_days)
    error_message = "Log retention days must be one of the valid CloudWatch retention periods."
  }
}

variable "log_kms_key_id" {
  description = "KMS key ID for encrypting CloudWatch logs"
  type        = string
  default     = null
}

# IAM and permissions
variable "additional_policies" {
  description = "Additional IAM policy statements for the Lambda execution role"
  type = list(object({
    Effect   = string
    Action   = list(string)
    Resource = list(string)
    Condition = optional(map(map(string)))
  }))
  default = []
}

# Service integration permissions
variable "allow_api_gateway" {
  description = "Allow API Gateway to invoke this Lambda function"
  type        = bool
  default     = false
}

variable "api_gateway_source_arn" {
  description = "Specific API Gateway ARN that can invoke this function (if null, allows all)"
  type        = string
  default     = null
}

variable "allow_eventbridge" {
  description = "Allow EventBridge to invoke this Lambda function"
  type        = bool
  default     = false
}

variable "eventbridge_rule_arn" {
  description = "EventBridge rule ARN that can invoke this function"
  type        = string
  default     = null
}

variable "allow_s3" {
  description = "Allow S3 to invoke this Lambda function"
  type        = bool
  default     = false
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN that can invoke this function"
  type        = string
  default     = null
}

# Tagging
variable "tags" {
  description = "Additional tags for the Lambda function and related resources"
  type        = map(string)
  default     = {}
}