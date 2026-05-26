terraform {
  required_providers {
    atlas = {
      source  = "ariga/atlas"
      version = "= 0.10.3"
    }
  }
}

provider "atlas" {}

data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = "../infra/terraform.tfstate"
  }
}

locals {
  role_files = sort(tolist(fileset("${path.module}/../../hcl/roles", "*.pg.hcl")))
  desired_hcl = join("\n\n", [
    for file_name in local.role_files : file("${path.module}/../../hcl/roles/${file_name}")
  ])
}

resource "atlas_schema" "roles" {
  env_name = "roles"
  config   = file("${path.module}/../../atlas.hcl")
  variables = jsonencode({
    endpoint           = data.terraform_remote_state.infra.outputs.db_endpoint
    aws_profile        = data.terraform_remote_state.infra.outputs.aws_profile
    database_name      = data.terraform_remote_state.infra.outputs.database_name
    region             = data.terraform_remote_state.infra.outputs.region
    master_secret_name = data.terraform_remote_state.infra.outputs.master_secret_name
    migrator_username  = data.terraform_remote_state.infra.outputs.migrator_username
  })
  hcl = local.desired_hcl
}

output "roles_resource_id" {
  value = atlas_schema.roles.id
}

output "migrator_username" {
  value = data.terraform_remote_state.infra.outputs.migrator_username
}
