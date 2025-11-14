output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.app.dns_name
}

output "blue_instance_id" {
  description = "ID of the blue EC2 instance"
  value       = aws_instance.app[local.blue_index].id
}

output "green_instance_id" {
  description = "ID of the green EC2 instance"
  value       = aws_instance.app[local.green_index].id
}

output "blue_instance_private_ip" {
  description = "Private IP of the blue IIS server"
  value       = aws_instance.app[local.blue_index].private_ip
}

output "green_instance_private_ip" {
  description = "Private IP of the green IIS server"
  value       = aws_instance.app[local.green_index].private_ip
}

output "rds_endpoint" {
  description = "RDS SQL Server endpoint"
  value       = aws_db_instance.sqlserver.address
}

output "rds_db_name" {
  description = "Logical application database name (used by the app/migrations)"
  value       = var.db_name
}

output "db_secret_name" {
  description = "Name of the Secrets Manager secret storing DB credentials"
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret storing DB credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}
