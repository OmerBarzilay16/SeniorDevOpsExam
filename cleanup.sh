#!/usr/bin/env bash
set -euo pipefail

PREFIX="senior-devops-exam"
REGION="us-east-2"

echo "=== Second-pass cleanup for: $PREFIX in $REGION ==="

#############################################
# 1. Delete Security Groups (retry-friendly)
#############################################
echo "--- Deleting Security Groups ---"

SG_IDS=$(aws ec2 describe-security-groups \
  --region "$REGION" \
  --query "SecurityGroups[?starts_with(GroupName, '${PREFIX}')].GroupId" \
  --output text || true)

if [[ -n "${SG_IDS}" ]]; then
  for SG in $SG_IDS; do
    echo "Trying to delete SG: $SG"
    aws ec2 delete-security-group --group-id "$SG" --region "$REGION" \
      || echo "Could not delete $SG (still has dependencies)"
  done
else
  echo "No matching SGs found."
fi

#############################################
# 2. Delete IAM roles & instance profiles
#############################################
echo "--- Deleting IAM roles & instance profiles ---"

ROLE="${PREFIX}-ec2-role"
PROFILE="${PREFIX}-ec2-instance-profile"

# Remove instance profile if exists
if aws iam get-instance-profile --instance-profile-name "$PROFILE" >/dev/null 2>&1; then
  echo "Removing role from instance profile..."
  aws iam remove-role-from-instance-profile \
    --instance-profile-name "$PROFILE" \
    --role-name "$ROLE" || true

  echo "Deleting instance profile..."
  aws iam delete-instance-profile \
    --instance-profile-name "$PROFILE" || true
fi

# Detach all attached managed policies (if role still exists)
if aws iam get-role --role-name "$ROLE" >/dev/null 2>&1; then
  ATTACHED_POLICIES=$(aws iam list-attached-role-policies \
    --role-name "$ROLE" \
    --query "AttachedPolicies[].PolicyArn" \
    --output text 2>/dev/null || true)

  for POLICY_ARN in $ATTACHED_POLICIES; do
    echo "Detaching managed policy $POLICY_ARN from role $ROLE"
    aws iam detach-role-policy \
      --role-name "$ROLE" \
      --policy-arn "$POLICY_ARN" || true
  done

  # Delete inline role policy if exists
  if aws iam get-role-policy --role-name "$ROLE" --policy-name "${PREFIX}-ec2-inline" >/dev/null 2>&1; then
    echo "Deleting inline role policy..."
    aws iam delete-role-policy \
      --role-name "$ROLE" \
      --policy-name "${PREFIX}-ec2-inline" || true
  fi

  echo "Deleting IAM role..."
  aws iam delete-role --role-name "$ROLE" || true
fi

#############################################
# 3. Delete RDS Subnet Group (retry)
#############################################
echo "--- Deleting RDS Subnet Group ---"
aws rds delete-db-subnet-group \
  --db-subnet-group-name "${PREFIX}-rds-subnets" \
  --region "$REGION" || echo "Subnet group still in use or already deleted"

echo "=== Cleanup complete (second pass). ==="
