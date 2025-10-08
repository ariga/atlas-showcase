variable "dialect" {
  type = string
}

locals {
  dev_url = {
    mysql = "docker://mysql/8/dev"
    postgresql = "docker://postgres/15"
    sqlite = "sqlite://?mode=memory&_fk=1"
    mssql = "docker://sqlserver/2022-latest"
    clickhouse = "docker://clickhouse/23.11/dev"
  }[var.dialect]
}

data "external_schema" "sqlalchemy" {
  program = [
    "atlas-provider-sqlalchemy",
    "--path", "app",
    "--dialect", var.dialect,
  ]
}

env "sqlalchemy" {
  src = data.external_schema.sqlalchemy.url
  dev = local.dev_url
  migration {
    dir = "file://migrations/${var.dialect}"
  }
}
