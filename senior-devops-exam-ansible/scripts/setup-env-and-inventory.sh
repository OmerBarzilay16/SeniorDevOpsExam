#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  echo "ERROR: This script must be sourced so env vars persist:"
  echo "  source scripts/setup-env-and-inventory.sh"
  exit 1
fi


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ANSIBLE_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"
ROOT_DIR="$( cd "$ANSIBLE_DIR/.." && pwd )"

TF_DIR="${TF_DIR:-$ROOT_DIR/senior-devops-exam-terraform-freetier}"
AWS_REGION="${AWS_REGION:-us-east-2}"

echo "=== SeniorDevOpsExam setup: env + inventory ==="
echo "--- Using Terraform dir: ${TF_DIR}"
echo "--- Using AWS region   : ${AWS_REGION}"


if ! cd "$TF_DIR"; then
  echo "ERROR: Cannot cd to ${TF_DIR}"
  return 1 2>/dev/null || exit 1
fi


export AWS_REGION
export RDS_SECRET_ARN="$(terraform output -raw db_secret_arn)"
export ALB_LISTENER_ARN="$(terraform output -raw alb_listener_arn)"
export TG_GREEN_ARN="$(terraform output -raw tg_green_arn 2>/dev/null || echo "")"
export TG_BLUE_ARN="$(terraform output -raw tg_blue_arn 2>/dev/null || echo "")"
export ALB_DNS_NAME="$(terraform output -raw alb_dns_name)"


echo "--- Exported env:"
echo "    AWS_REGION=${AWS_REGION}"
echo "    RDS_SECRET_ARN=${RDS_SECRET_ARN}"
echo "    ALB_LISTENER_ARN=${ALB_LISTENER_ARN}"
echo "    TG_GREEN_ARN=${TG_GREEN_ARN}"
echo "    TG_BLUE_ARN=${TG_BLUE_ARN}"
echo "    ALB_DNS_NAME=${ALB_DNS_NAME}"


echo "--- Discovering EC2 public IPs for blue/green ---"
BLUE_ID="$(terraform output -raw blue_instance_id)"
GREEN_ID="$(terraform output -raw green_instance_id)"

BLUE_IP="$(aws ec2 describe-instances \
  --region "$AWS_REGION" \
  --instance-ids "$BLUE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)"

GREEN_IP="$(aws ec2 describe-instances \
  --region "$AWS_REGION" \
  --instance-ids "$GREEN_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)"

echo "    blue  -> ${BLUE_IP}"
echo "    green -> ${GREEN_IP}"


cd "$ANSIBLE_DIR" || {
  echo "ERROR: Cannot cd back to ${ANSIBLE_DIR}"
  return 1 2>/dev/null || exit 1
}

INVENTORY_DIR="${ANSIBLE_DIR}/inventory"
INVENTORY_PATH="${INVENTORY_DIR}/hosts.yml"

mkdir -p "$INVENTORY_DIR"

cat > "$INVENTORY_PATH" <<EOF
all:
  children:
    logviewer:
      hosts:
        blue:
          ansible_host: ${BLUE_IP}
        green:
          ansible_host: ${GREEN_IP}
      vars:
        ansible_user: Administrator
        ansible_connection: winrm
        ansible_port: 5986
        ansible_winrm_scheme: https
        ansible_winrm_transport: basic
        ansible_winrm_server_cert_validation: ignore
EOF

echo "--- Inventory updated at: ${INVENTORY_PATH}"
echo "=== Setup complete. You can now run: ./scripts/run-ansible.sh ==="
