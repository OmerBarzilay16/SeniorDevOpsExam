#!/usr/bin/env bash
set -euo pipefail

TF_DIR="/mnt/c/Users/Direct/Desktop/SeniorDevOpsExam/senior-devops-exam-terraform-freetier"
AWS_REGION="us-east-2"

BLUE_ID=$(cd "$TF_DIR" && terraform output -raw blue_instance_id)

echo "Opening SSM Session Manager to blue instance: $BLUE_ID"
aws ssm start-session \
  --region "$AWS_REGION" \
  --target "$BLUE_ID"
