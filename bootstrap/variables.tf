# -------------------------------------------------------
# variables.tf — Input variables for the Nginx deployment
# -------------------------------------------------------

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for storing Terraform remote state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name used for Terraform state locking"
  type        = string
}