# AWS Lambda Module

This module creates an AWS Lambda function with standardized configuration, security best practices, and comprehensive monitoring setup.

## Features

- **Secure by Default**: Proper IAM roles with least-privilege access
- **Multiple Deployment Options**: Local zip files or S3-based deployment
- **Comprehensive Logging**: Automatic CloudWatch log group creation with retention policies
- **VPC Support**: Optional VPC integration for private resource access
- **Service Integration**: Built-in permissions for API Gateway, EventBridge, and S3
- **Monitoring**: Optional X-Ray tracing and dead letter queue configuration
- **Layer Support**: Attach up to 5 Lambda layers
- **Environment Variables**: Secure environment variable management with KMS encryption

## Usage

### Basic Usage

```hcl
module "lambda_function" {
  source = "git::https://github.com/imdushyant25/terraform-aws-modules.git//modules/lambda"
  
  function_name = "data-processor"
  runtime       = "python3.11"
  handler       = "lambda_function.lambda_handler"
  
  # Deploy from local source code
  source_code_path = "./src"
  
  environment = "dev"
  team        = "data-team"
  
  tags = {
    Project = "Data Pipeline"
    Owner   = "data-team@company.com"
  }
}
```

### Advanced Usage with S3 Deployment

```hcl
module "api_lambda" {
  source = "git::https://github.com/imdushyant25/terraform-aws-modules.git//modules/lambda"
  
  function_name = "api-handler"
  description   = "API request handler for user service"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  timeout       = 60
  memory_size   = 512
  
  # Deploy from S3
  s3_bucket = "my-deployment-bucket"
  s3_key    = "lambda-deployments/api-handler-v1.0.0.zip"
  
  # Environment variables with encryption
  environment_variables = {
    DATABASE_URL = "postgresql://..."
    API_KEY      = "encrypted-api-key"
    LOG_LEVEL    = "INFO"
  }
  kms_key_arn = aws_kms_key.lambda_encryption.arn
  
  # Service integrations
  allow_api_gateway = true
  allow_eventbridge = true
  
  # Additional IAM permissions
  additional_policies = [
    {
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ]
      Resource = [
        aws_dynamodb_table.users.arn
      ]
    }
  ]
  
  # Monitoring and error handling
  enable_tracing         = true
  dlq_target_arn        = aws_sqs_queue.lambda_dlq.arn
  log_retention_days    = 30
  
  environment = "prod"
  team        = "backend-team"
  
  tags = {
    Project     = "User Service API"
    Environment = "production"
    CriticalApp = "true"
  }
}
```

### VPC Integration

```hcl
module "vpc_lambda" {
  source = "git::https://github.com/imdushyant25/terraform-aws-modules.git//modules/lambda"
  
  function_name = "database-processor"
  runtime       = "python3.11"
  handler       = "app.handler"
  
  source_code_path = "./database-processor"
  
  # VPC configuration for private resource access
  vpc_config = {
    subnet_ids = [
      aws_subnet.private_subnet_1.id,
      aws_subnet.private_subnet_2.id
    ]
    security_group_ids = [
      aws_security_group.lambda_sg.id
    ]
  }
  
  # Increased timeout for database operations
  timeout     = 300
  memory_size = 1024
  
  environment = "prod"
  team        = "data-team"
}
```

### With Lambda Layers

```hcl
module "layered_lambda" {
  source = "git::https://github.com/imdushyant25/terraform-aws-modules.git//modules/lambda"
  
  function_name = "ml-inference"
  runtime       = "python3.11"
  handler       = "inference.handler"
  
  source_code_path = "./inference-function"
  
  # Attach shared layers
  layer_arns = [
    "arn:aws:lambda:us-east-1:123456789012:layer:numpy-pandas:1",
    "arn:aws:lambda:us-east-1:123456789012:layer:scikit-learn:2"
  ]
  
  memory_size = 2048
  timeout     = 900
  
  environment = "prod"
  team        = "ml-team"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |
| archive | >= 2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lambda_function.function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_iam_role.lambda_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_basic_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_vpc_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy.lambda_custom_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_cloudwatch_log_group.lambda_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_lambda_permission.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| function\_name | Name of the Lambda function (environment will be appended) | `string` | n/a | yes |
| runtime | Runtime for the Lambda function | `string` | n/a | yes |
| handler | Entry point for the Lambda function | `string` | n/a | yes |
| environment | Environment name (e.g., dev, staging, prod) | `string` | n/a | yes |
| team | Team responsible for this Lambda function | `string` | n/a | yes |
| source\_code\_path | Path to the source code directory (alternative to S3 deployment) | `string` | `null` | no |
| s3\_bucket | S3 bucket containing the deployment package | `string` | `null` | no |
| s3\_key | S3 key of the deployment package | `string` | `null` | no |
| s3\_object\_version | S3 object version of the deployment package | `string` | `null` | no |
| description | Description of the Lambda function | `string` | `"Lambda function managed by Terraform"` | no |
| timeout | Timeout for the Lambda function in seconds | `number` | `30` | no |
| memory\_size | Memory size for the Lambda function in MB | `number` | `128` | no |
| environment\_variables | Environment variables for the Lambda function | `map(string)` | `null` | no |
| kms\_key\_arn | KMS key ARN for encrypting environment variables | `string` | `null` | no |
| vpc\_config | VPC configuration for the Lambda function | `object({...})` | `null` | no |
| layer\_arns | List of Lambda layer ARNs to attach to the function | `list(string)` | `[]` | no |
| dlq\_target\_arn | ARN of SQS queue or SNS topic for dead letter queue | `string` | `null` | no |
| reserved\_concurrent\_executions | Reserved concurrent executions for the Lambda function | `number` | `null` | no |
| enable\_tracing | Enable AWS X-Ray tracing | `bool` | `false` | no |
| log\_retention\_days | CloudWatch log retention period in days | `number` | `14` | no |
| log\_kms\_key\_id | KMS key ID for encrypting CloudWatch logs | `string` | `null` | no |
| additional\_policies | Additional IAM policy statements for the Lambda execution role | `list(object({...}))` | `[]` | no |
| allow\_api\_gateway | Allow API Gateway to invoke this Lambda function | `bool` | `false` | no |
| api\_gateway\_source\_arn | Specific API Gateway ARN that can invoke this function | `string` | `null` | no |
| allow\_eventbridge | Allow EventBridge to invoke this Lambda function | `bool` | `false` | no |
| eventbridge\_rule\_arn | EventBridge rule ARN that can invoke this function | `string` | `null` | no |
| allow\_s3 | Allow S3 to invoke this Lambda function | `bool` | `false` | no |
| s3\_bucket\_arn | S3 bucket ARN that can invoke this function | `string` | `null` | no |
| tags | Additional tags for the Lambda function and related resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| function\_name | Name of the Lambda function |
| function\_arn | ARN of the Lambda function |
| invoke\_arn | Invoke ARN of the Lambda function (for use with API Gateway) |
| qualified\_arn | Qualified ARN of the Lambda function |
| version | Latest published version of the Lambda function |
| execution\_role\_arn | ARN of the Lambda execution role |
| execution\_role\_name | Name of the Lambda execution role |
| log\_group\_name | Name of the CloudWatch log group |
| log\_group\_arn | ARN of the CloudWatch log group |

## Validation Rules

- **Function name**: Must contain only alphanumeric characters, hyphens, and underscores
- **Runtime**: Must be one of the supported Lambda runtimes
- **Environment**: Must be one of: dev, develop, test, staging, stage, prod, production
- **Timeout**: Must be between 1 and 900 seconds
- **Memory size**: Must be between 128 MB and 10,240 MB
- **Layers**: Maximum of 5 layers can be attached
- **Log retention**: Must be one of the valid CloudWatch retention periods

## Security Features

1. **Least Privilege IAM**: Execution role includes only necessary permissions
2. **Encryption**: Support for KMS encryption of environment variables and logs
3. **VPC Integration**: Optional VPC deployment for private resource access
4. **Secure Defaults**: All security settings enabled by default
5. **Resource Isolation**: Proper tagging for resource management and cost allocation

## Monitoring and Observability

- **CloudWatch Logs**: Automatic log group creation with configurable retention
- **X-Ray Tracing**: Optional distributed tracing support
- **Dead Letter Queue**: Error handling with SQS or SNS integration
- **Metrics**: Built-in CloudWatch metrics for performance monitoring

## Common Use Cases

1. **API Backends**: REST API handlers with API Gateway integration
2. **Event Processing**: Event-driven processing with EventBridge/SQS triggers
3. **Data Processing**: ETL jobs and data transformation pipelines
4. **Scheduled Tasks**: Cron-like functionality with EventBridge rules
5. **File Processing**: S3 event-triggered document processing
6. **Microservices**: Individual service components in serverless architecture

## Notes

- Either `source_code_path` OR (`s3_bucket` + `s3_key`) must be provided for code deployment
- VPC configuration is optional but required for accessing private resources
- The module automatically creates required IAM roles and CloudWatch log groups
- Function names are automatically suffixed with the environment name
- All resources are tagged according to organizational standards