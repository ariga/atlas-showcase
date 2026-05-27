variable "endpoint" {
  type = string
}

variable "aws_profile" {
  type = string
}

variable "database_name" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "master_secret_name" {
  type = string
}

variable "migrator_username" {
  type    = string
  default = "atlas_migrator"
}

data "runtimevar" "master_secret" {
  url = "awssecretsmanager://${var.master_secret_name}?region=${var.region}&awssdk=v2&profile=${var.aws_profile}"
}

data "aws_rds_token" "migrator" {
  region   = var.region
  endpoint = var.endpoint
  profile  = var.aws_profile
  username = var.migrator_username
}

env "roles" {
  url = "postgres://${jsondecode(data.runtimevar.master_secret).username}:${urlescape(jsondecode(data.runtimevar.master_secret).password)}@${var.endpoint}/${var.database_name}?sslmode=require"
  schema {
    mode {
      roles       = true
      permissions = true
      tables      = false
      views       = false
      funcs       = false
      types       = false
      objects     = false
      triggers    = false
    }
  }
}

env "schema" {
  url = "postgres://${var.migrator_username}:${urlescape(data.aws_rds_token.migrator)}@${var.endpoint}/${var.database_name}?sslmode=require"
}
