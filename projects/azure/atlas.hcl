env "azure" {
  src = "file://schema.sql"
  url = "docker://postgres/15/dev?search_path=public"
  dev = "docker://postgres/15/dev?search_path=public"
}


env {
    name = atlas.env
    url = "postgres://postgres:postgres@localhost/postgres?sslmode=disable"
    dev = "docker://postgres/16/dev"
    schema {
      src = "file://main.sql"
      repo {
        name = "azure-demo"
      }
    }
}