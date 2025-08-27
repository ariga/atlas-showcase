variable "clickhouse_url" {
  type = string
  description = "Clickhouse connection string"
  default = getenv("CLICKHOUSE_URL")
}

variable "clickhouse_dev_url" {
  type = string
  description = "Clickhouse Dev connection string"
  default = getenv("CLICKHOUSE_DEV_URL")
}

env "local" {
    url = var.clickhouse_url
    dev = var.clickhouse_dev_url
    schema {
      src = "file://schema.sql"
      repo {
        name = "clickhouse-demo"
      }
    }
}
