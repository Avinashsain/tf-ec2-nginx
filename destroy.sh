#!/usr/bin/env bash
# -------------------------------------------------------
# destroy.sh — Tears down everything in the right order
# -------------------------------------------------------

set -euo pipefail


# -------------------------------------------------------
# Read values directly from terraform.tfvars
# -------------------------------------------------------
TFVARS="$(dirname "$0")/terraform.tfvars"
 
get_var() {
  grep -E "^$1\s*=" "$TFVARS" | sed 's/.*=\s*"\(.*\)"/\1/' | tr -d ' '
}
 
REGION=$(get_var "aws_region")
BUCKET=$(get_var "state_bucket_name")
DYNAMO=$(get_var "dynamodb_table_name")

echo ""
echo "=============================================="
echo " STEP 1: Re-initialising main module"
echo "=============================================="
terraform init -input=false -reconfigure \
  -backend-config="bucket=${BUCKET}" \
  -backend-config="region=${REGION}" \
  -backend-config="key=nginx-ec2/terraform.tfstate" \
  -backend-config="use_lockfile=true" \
  -backend-config="encrypt=true"

echo ""
echo "=============================================="
echo " STEP 2: Destroying EC2 Nginx infrastructure"
echo "=============================================="
terraform destroy -input=false -auto-approve \
  -var="aws_region=${REGION}"

echo ""
echo "=============================================="
echo " STEP 3: Destroying S3 backend + DynamoDB lock"
echo "=============================================="
cd bootstrap
terraform init -input=false -reconfigure
terraform destroy -input=false -auto-approve \
  -var="aws_region=${REGION}" \
  -var="state_bucket_name=${BUCKET}" \
  -var="dynamodb_table_name=${DYNAMO}"
cd ..

echo ""
echo "=============================================="
echo " All resources destroyed successfully."
echo "=============================================="