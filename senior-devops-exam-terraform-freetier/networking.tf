data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "alb" {
  name        = "${local.project_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow HTTP from everywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.project_name}-alb-sg"
  }
}

resource "aws_security_group" "ec2" {
  name        = "${local.project_name}-ec2-sg"
  description = "Security group for IIS EC2 instances"
  vpc_id      = data.aws_vpc.default.id

  # HTTP from ALB
  ingress {
    description = "Allow HTTP from ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [
      aws_security_group.alb.id
    ]
  }

  # RDP for admin access from your IP
  ingress {
    description = "Allow RDP from admin IP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [var.allowed_admin_cidr]
  }

  # WinRM over HTTPS for Ansible from your IP
  ingress {
    description = "Allow WinRM over HTTPS from admin IP"
    from_port   = 5986
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = [var.allowed_admin_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.project_name}-ec2-sg"
  }
}

resource "aws_security_group" "rds" {
  name        = "${local.project_name}-rds-sg"
  description = "Security group for RDS SQL Server"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow SQL Server from EC2"
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    security_groups = [
      aws_security_group.ec2.id
    ]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.project_name}-rds-sg"
  }
}
