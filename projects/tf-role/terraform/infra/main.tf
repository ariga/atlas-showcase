terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_secretsmanager_secret" "master" {
  arn = one(aws_db_instance.this.master_user_secret[*].secret_arn)
}

locals {
  name              = var.name
  master_username   = "postgres"
  migrator_username = "atlas_migrator"
  database_name     = "appdb"

  tags = {
    Project = "rds-pg-guide"
  }
}

resource "aws_security_group" "rds" {
  name        = "${local.name}-rds"
  description = "RDS PostgreSQL access for Atlas IAM guide"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "PostgreSQL from current public IP"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.name}-rds"
  })
}

resource "aws_db_subnet_group" "this" {
  name       = local.name
  subnet_ids = data.aws_subnets.default.ids

  tags = merge(local.tags, {
    Name = local.name
  })
}

resource "aws_db_instance" "this" {
  identifier = local.name

  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = local.database_name
  username = local.master_username
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = true

  iam_database_authentication_enabled = true

  backup_retention_period = 0
  deletion_protection     = false
  skip_final_snapshot     = true
  apply_immediately       = true

  tags = local.tags
}

resource "aws_iam_policy" "rds_connect" {
  name        = "${local.name}-rds-connect"
  description = "Allow IAM database authentication as ${local.migrator_username} on ${local.name}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "rds-db:connect"
        Resource = "arn:${data.aws_partition.current.partition}:rds-db:${var.region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.this.resource_id}/${local.migrator_username}"
      }
    ]
  })
}
