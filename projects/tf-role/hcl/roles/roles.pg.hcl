role "rds_ad" {
  external = true
}

role "rds_extension" {
  external = true
}

role "rds_iam" {
  external = true
}

role "rds_password" {
  external = true
}

role "rds_replication" {
  external = true
}

role "rds_reserved" {
  external = true
}

role "rds_superuser" {
  external = true
}

user "rdsadmin" {
  external = true
}

user "postgres" {
  external = true
}

user "atlas_migrator" {
  member_of = [role.rds_iam]
}

user "app_reader" {}
