env {
  name = atlas.env
  dev  = "docker://postgres/17/dev"
  script {
    src = "file://examples"
    repo {
      name = "scripts"
    }
  }
}
