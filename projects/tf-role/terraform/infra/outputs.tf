output "region" {
  value = var.region
}

output "aws_profile" {
  value = var.aws_profile
}

output "db_address" {
  value = aws_db_instance.this.address
}

output "db_port" {
  value = aws_db_instance.this.port
}

output "db_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "database_name" {
  value = local.database_name
}

output "master_secret_name" {
  value = data.aws_secretsmanager_secret.master.name
}

output "migrator_username" {
  value = local.migrator_username
}

output "connect_iam_policy_arn" {
  value = aws_iam_policy.rds_connect.arn
}

output "rds_db_connect_resource" {
  value = "arn:${data.aws_partition.current.partition}:rds-db:${var.region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.this.resource_id}/${local.migrator_username}"
}

output "security_group_id" {
  value = aws_security_group.rds.id
}
