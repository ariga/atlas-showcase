env "local" {
  schema {
    src = "file://schema.sql"
    mode {
      roles       = true
      permissions = true
    }
  }
  dev = "docker://mysql/8/dev"
  migration {
    dir = "file://migrations"
  }
  format {
    migrate {
      diff = "{{ sql . \"  \" }}"
    }
  }
}
