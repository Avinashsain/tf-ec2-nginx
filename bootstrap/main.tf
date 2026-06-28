# -------------------------------------------------------
# bootstrap/main.tf
# Purpose: Create S3 bucket + DynamoDB lock table ONCE.
# This module uses LOCAL state (no backend needed).
# Run via init.sh — do NOT run manually.
# -------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

# -------------------------------------------------------
# S3 Bucket — will store the main project's remote state
# -------------------------------------------------------
resource "aws_s3_bucket" "tf_state" {
  bucket        = var.state_bucket_name
  force_destroy = true

  tags = {
    Name      = "terraform-state-bucket"
    ManagedBy = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# -------------------------------------------------------
# DynamoDB Table — state lock (LockID is required by Terraform)
# -------------------------------------------------------
resource "aws_dynamodb_table" "tf_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name      = "terraform-state-lock"
    ManagedBy = "Terraform"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.tf_state.bucket
}

output "dynamodb_table" {
  value = aws_dynamodb_table.tf_locks.name
}
