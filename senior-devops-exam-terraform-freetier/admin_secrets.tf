# Generate a strong random password for the Windows Administrator user
resource "random_password" "windows_admin" {
  length  = 20
  special = true
}

# Secret to store the admin password
resource "aws_secretsmanager_secret" "windows_admin_password" {
  name        = "senior-devops-exam-windows-admin-password"
  description = "Password for local Administrator on LogViewer Windows instances (blue/green)"
}

# Secret value = just the password string (no JSON, so we don't need jq later)
resource "aws_secretsmanager_secret_version" "windows_admin_password_version" {
  secret_id     = aws_secretsmanager_secret.windows_admin_password.id
  secret_string = random_password.windows_admin.result
}

# Output the secret ARN so Ansible can look it up
output "windows_admin_password_secret_arn" {
  value = aws_secretsmanager_secret.windows_admin_password.arn
}
