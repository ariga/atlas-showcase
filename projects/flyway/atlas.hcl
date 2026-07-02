env "local" {
  url = "mysql://root:admin@localhost:3306/test"
  dev = "docker://mysql/8/dev"
  migration {
    dir = "file://atlas-migrations"
  }
}

env "production" {
  url = "mysql://user:pass@prod-server:3306/prod"
  dev = "docker://mysql/8/dev"
  migration {
    dir = "file://atlas-migrations"
  }
}