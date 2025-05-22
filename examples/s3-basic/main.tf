```hcl
provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}

module "example_bucket" {
  source = "../../modules/s3"
  
  bucket_name  = "my-first-terraform-bucket-unique-suffix"
  environment  = "dev"
  team         = "learning"
  
  tags = {
    Purpose = "Learning Terraform"
  }
}

output "bucket_name" {
  value = module.example_bucket.bucket_id
}