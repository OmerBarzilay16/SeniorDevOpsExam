resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${local.project_name}-db-credentials-v2"
  description = "RDS SQL Server credentials and connection details for LogViewer app"

  tags = {
    Name = "${local.project_name}-db-credentials-v2"
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    port     = aws_db_instance.sqlserver.port
    url      = aws_db_instance.sqlserver.address
    name     = var.db_name
  })
}
