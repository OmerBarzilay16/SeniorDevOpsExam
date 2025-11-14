resource "aws_db_subnet_group" "sqlserver" {
  name       = "${local.project_name}-rds-subnets"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "${local.project_name}-rds-subnets"
  }
}

resource "aws_db_instance" "sqlserver" {
  identifier        = "${local.project_name}-sqlserver"
  engine            = "sqlserver-ex"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  # For SQL Server, DBName (db_name) must be null; we manage the logical DB in migrations.
  username = var.db_username
  password = var.db_password

  port                   = 1433
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.sqlserver.name

  multi_az                = false
  publicly_accessible     = false
  backup_retention_period = 0
  skip_final_snapshot     = true

  tags = {
    Name = "${local.project_name}-sqlserver"
  }
}
