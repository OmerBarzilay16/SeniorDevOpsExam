data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  blue_index  = 0
  green_index = 1
}

resource "aws_instance" "app" {
  count         = 2
  ami           = data.aws_ami.windows.id
  instance_type = var.ec2_instance_type
  subnet_id     = element(data.aws_subnets.default.ids, count.index)

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true

  # Use the PowerShell bootstrap template to:
  # - set Administrator password
  # - enable WinRM over HTTPS
  # - open firewall ports
  user_data = templatefile("${path.module}/template/windows_bootstrap.ps1.tpl", {
    admin_password = random_password.windows_admin.result
  })

  tags = {
    Name      = count.index == local.blue_index ? local.blue_name : local.green_name
    Role      = count.index == local.blue_index ? "blue" : "green"
    Terraform = "true"
  }
}