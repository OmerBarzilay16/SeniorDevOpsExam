terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "random" {}

locals {
  project_name = var.project_name
  blue_name    = "${local.project_name}-blue"
  green_name   = "${local.project_name}-green"
}
