variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Base name/prefix for all resources"
  type        = string
  default     = "senior-devops-exam"
}

variable "ec2_instance_type" {
  description = "Instance type for Windows EC2 instances (free tier eligible when t2.micro/t3.micro and within limits)"
  type        = string
  default     = "t3.micro"
}

variable "allowed_admin_cidr" {
  description = "Your IP/CIDR allowed for WinRM/RDP (e.g. 1.2.3.4/32)"
  type        = string
}

variable "db_username" {
  description = "Master username for SQL Server RDS"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Master password for SQL Server RDS"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name to create on RDS"
  type        = string
  default     = "LogViewerDb"
}
