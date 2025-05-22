# S3 Bucket Module

This module creates an S3 bucket with standardized configuration.

## Usage

```hcl
module "s3_bucket" {
  source = "git::https://github.com/imdushyant25/terraform-aws-modules.git//modules/s3"
  
  bucket_name     = "app-dev-data"
  environment     = "dev"
  team            = "data-team"
  
  # Optional configurations
  versioning_enabled = true
  encryption_enabled = true
  
  # Additional tags
  tags = {
    Project = "Data Lake"
  }
}