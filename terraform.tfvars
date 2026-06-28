# -------------------------------------------------------
# terraform.tfvars — Actual values for all variables
# -------------------------------------------------------

aws_region          = "us-east-1"
instance_type       = "t2.micro"
key_name            = "nginx-key"
public_key_path     = "~/.ssh/id_rsa.pub"     # Path to your public key
state_bucket_name   = "tf-nginx-state-bucket" # Must be globally unique
dynamodb_table_name = "tf-nginx-lock-table"

html_title = "Terraform Nginx Server"
html_body  = "<h1>Welcome to the Terraform-managed Nginx Server on Ubuntu</h1><p>Deployed via Terraform.</p>"