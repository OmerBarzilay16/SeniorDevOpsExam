#!/usr/bin/env bash
set -euo pipefail

TF_DIR="/mnt/c/Users/Direct/Desktop/SeniorDevOpsExam/senior-devops-exam-terraform-freetier"
AWS_REGION="us-east-2"

GREEN_ID=$(cd "$TF_DIR" && terraform output -raw green_instance_id)

echo "Opening SSM Session Manager to green instance: $GREEN_ID"
aws ssm start-session \
  --region "$AWS_REGION" \
  --target "$GREEN_ID"
