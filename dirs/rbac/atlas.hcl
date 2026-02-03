env "local" {
  dev = "docker://postgres/17/dev"
  schema {
    src = "file://schema.sql"
    mode {
      permissions = true
      roles       = true
    }
  }
}
