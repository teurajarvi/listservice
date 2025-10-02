#!/usr/bin/env bash
# Initialize Terraform remote backend (S3 + DynamoDB lock)
# Usage: REGION=eu-north-1 BUCKET=<name> TABLE=<name> ./scripts/init_backend.sh

set -euo pipefail
: "${REGION:?Set REGION}"
: "${BUCKET:?Set BUCKET}"
: "${TABLE:?Set TABLE}"

aws s3api create-bucket --bucket "$BUCKET" --region "$REGION"   --create-bucket-configuration LocationConstraint="$REGION" >/dev/null 2>&1 || true

aws s3api put-bucket-versioning --bucket "$BUCKET" --versioning-configuration Status=Enabled

aws dynamodb create-table   --table-name "$TABLE"   --attribute-definitions AttributeName=LockID,AttributeType=S   --key-schema AttributeName=LockID,KeyType=HASH   --billing-mode PAY_PER_REQUEST   --region "$REGION" >/dev/null 2>&1 || true

cat > infra/backend.tf <<EOF
terraform {
  backend "s3" {
    bucket         = "${BUCKET}"
    key            = "listservice/terraform.tfstate"
    region         = "${REGION}"
    dynamodb_table = "${TABLE}"
    encrypt        = true
  }
}
EOF

echo "backend.tf created for bucket=${BUCKET}, table=${TABLE}, region=${REGION}"
