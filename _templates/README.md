# AWS Service Catalog Templates

This directory contains ready-to-use infrastructure templates that teams can copy and customize for their projects.

## 📋 Available Templates

### 1. Simple Lambda Function (`simple-lambda/`)
**Use Case**: Basic serverless function for simple tasks
- Single Lambda function with monitoring
- Configurable runtime, memory, and timeout
- CloudWatch dashboard included
- Easy to customize for any simple function

**Perfect for**:
- API endpoints
- Utility functions
- Scheduled tasks
- Simple data transformations

### 2. Data Pipeline (`data-pipeline/`)
**Use Case**: Process files uploaded to S3
- Input S3 bucket → Lambda processor → Output S3 bucket
- Automatic S3 event triggers
- Dead letter queue for error handling
- CloudWatch alarms for monitoring

**Perfect for**:
- File processing (CSV, JSON, images)
- ETL pipelines
- Data transformation workflows
- Batch processing jobs

## 🚀 How to Use Templates

### Step 1: Copy Template
```bash
# Copy the template you want to use
cp -r templates/simple-lambda/ my-project/
cd my-project/
```

### Step 2: Customize Configuration
```bash
# Copy and edit the configuration file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your project details
```

### Step 3: Add Your Code
```bash
# Add your application code
mkdir src
# Add your Lambda function code to src/
```

### Step 4: Deploy
```bash
cd infrastructure/
terraform init
terraform plan
terraform apply
```

## 📁 Template Structure

Each template follows this structure:
```
template-name/
├── README.md                    # Template-specific documentation
├── infrastructure/
│   ├── main.tf                  # Main infrastructure code
│   ├── variables.tf             # Input variables
│   ├── outputs.tf               # Outputs
│   └── terraform.tfvars.example # Example configuration
├── src/                         # Sample application code
│   └── lambda_function.py       # Example function
└── docs/
    └── architecture.md          # Architecture explanation
```

## 🔧 Customization Guide

### Common Customizations

1. **Change Function Configuration**:
   ```hcl
   # In terraform.tfvars
   timeout     = 300    # 5 minutes
   memory_size = 1024   # 1GB RAM
   ```

2. **Add AWS Service Permissions**:
   ```hcl
   additional_policies = [
     {
       Effect = "Allow"
       Action = ["dynamodb:GetItem", "dynamodb:PutItem"]
       Resource = ["arn:aws:dynamodb:*:*:table/my-table"]
     }
   ]
   ```

3. **Set Environment Variables**:
   ```hcl
   environment_variables = {
     DATABASE_URL = "postgresql://..."
     API_KEY      = "your-api-key"
     LOG_LEVEL    = "DEBUG"
   }
   ```

### Team-Specific Customizations

Teams typically customize:
- **Function names** and descriptions
- **Memory and timeout** settings
- **Environment variables** for their application
- **IAM permissions** for AWS services they use
- **Monitoring and alerting** thresholds

## 📊 Monitoring and Troubleshooting

All templates include:
- **CloudWatch Logs**: Automatic log group creation
- **CloudWatch Metrics**: Function performance metrics
- **Optional Dashboards**: Visual monitoring (set `create_dashboard = true`)
- **Optional Alarms**: Error alerting (set `create_alarms = true`)

### Common Commands
```bash
# View function logs
aws logs tail /aws/lambda/your-function-name --follow

# Test function
aws lambda invoke --function-name your-function-name --payload '{}' response.json

# Check metrics
aws cloudwatch get-metric-statistics --namespace AWS/Lambda --metric-name Duration --dimensions Name=FunctionName,Value=your-function-name --start-time 2023-01-01T00:00:00Z --end-time 2023-01-01T23:59:59Z --period 3600 --statistics Average
```

## 🏗️ Template Development Guidelines

When creating new templates:

1. **Follow the standard structure** shown above
2. **Include comprehensive documentation**
3. **Provide working example code**
4. **Use sensible defaults** for all variables
5. **Include monitoring and error handling**
6. **Tag all resources consistently**
7. **Follow security best practices**

## 📞 Getting Help

- **Documentation**: Check the template's README.md
- **Examples**: Look at the example configuration files
- **Issues**: Contact the platform team
- **Office Hours**: Weekly sessions for template support

## 🔄 Template Updates

Templates are versioned and updated regularly:
- **Breaking changes** are announced with migration guides
- **New features** are added based on team feedback
- **Security updates** are applied automatically
- **Best practices** are continuously incorporated

Stay updated by watching the service catalog repository!