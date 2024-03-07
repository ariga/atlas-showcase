env "local" {
  src = "file://inventory/schema.hcl"
  dev = "docker://mysql/8/default"
  migration  {
    dir = "file://inventory/migrations"
  }
  format {
    migrate {
      diff = "{{ sql . \"  \" }}"
    }
  }
}