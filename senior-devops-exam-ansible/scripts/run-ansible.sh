#!/usr/bin/env bash
set -euo pipefail

PLAYBOOK="${1:-playbooks/site.yml}"
TF_DIR="/mnt/c/Users/Direct/Desktop/SeniorDevOpsExam/senior-devops-exam-terraform-freetier"
REGION="us-east-2"

# 1) Get the ARN of the Windows admin password secret from Terraform
SECRET_ARN=$(cd "$TF_DIR" && terraform output -raw windows_admin_password_secret_arn)
echo "Using secret: $SECRET_ARN"

# 2) Fetch the actual Administrator password from Secrets Manager
SECRET_VALUE=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ARN" \
  --region "$REGION" \
  --query SecretString \
  --output text)

echo "Fetched password length: ${#SECRET_VALUE}"

# 3) Run Ansible, injecting the password into ansible_password / ansible_winrm_password
ANSIBLE_ROLES_PATH=./roles \
ansible-playbook -i inventory/hosts.yml "$PLAYBOOK" \
  -e "ansible_password=${SECRET_VALUE}" \
  -e "ansible_winrm_password=${SECRET_VALUE}" \
  --vault-id @prompt
