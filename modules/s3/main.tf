resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = merge(var.tags, {
    ManagedBy   = "Terraform"
    Environment = var.environment
    Team        = var.team
  })
}

# Enable versioning if specified
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

# Enable encryption if specified
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}