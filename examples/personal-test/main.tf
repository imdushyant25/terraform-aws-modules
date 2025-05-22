provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}

module "test_bucket" {
  source = "../../modules/s3"
  
  bucket_name     = "personal-test-bucket-${random_id.suffix.hex}"
  environment     = "dev"
  team            = "personal"
  
  tags = {
    Purpose = "Personal Testing"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

output "bucket_name" {
  value = module.test_bucket.bucket_id
}