#!/usr/bin/env bash
# -------------------------------------------------------
# destroy.sh — Teardown in correct order
# All values are read from terraform.tfvars — no hardcoding
# -------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TFVARS="${SCRIPT_DIR}/terraform.tfvars"

# Read a variable value from terraform.tfvars
# Strips key, quotes, inline comments, and whitespace
get_var() {
  grep -E "^${1}\s*=" "$TFVARS" \
    | sed 's/^[^=]*=\s*//' \
    | sed 's/#.*//' \
    | tr -d '"' \
    | tr -d "'" \
    | xargs
}

REGION=$(get_var "aws_region")
BUCKET=$(get_var "state_bucket_name")
DYNAMO=$(get_var "dynamodb_table_name")

echo ""
echo "Using values from terraform.tfvars:"
echo "  aws_region          = ${REGION}"
echo "  state_bucket_name   = ${BUCKET}"
echo "  dynamodb_table_name = ${DYNAMO}"
echo ""

echo "=============================================="
echo " STEP 1: Re-initialising main module"
echo "=============================================="
cd "${SCRIPT_DIR}"
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
  -var-file="terraform.tfvars"

echo ""
echo "=============================================="
echo " STEP 3: Destroying S3 backend + DynamoDB lock"
echo "=============================================="
cd "${SCRIPT_DIR}/bootstrap"
terraform init -input=false -reconfigure
terraform destroy -input=false -auto-approve \
  -var="aws_region=${REGION}" \
  -var="state_bucket_name=${BUCKET}" \
  -var="dynamodb_table_name=${DYNAMO}"

echo ""
echo "=============================================="
echo " All resources destroyed successfully."
echo "=============================================="