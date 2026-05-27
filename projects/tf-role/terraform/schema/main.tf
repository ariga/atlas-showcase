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

data "terraform_remote_state" "roles" {
  backend = "local"

  config = {
    path = "../roles/terraform.tfstate"
  }
}

locals {
  schema_files = sort(tolist(fileset("${path.module}/../../hcl/schema", "*.pg.hcl")))
  desired_hcl = join("\n\n", [
    for file_name in local.schema_files : file("${path.module}/../../hcl/schema/${file_name}")
  ])
}

resource "atlas_schema" "app" {
  env_name = "schema"
  config   = file("${path.module}/../../atlas.hcl")
  variables = jsonencode({
    endpoint           = data.terraform_remote_state.infra.outputs.db_endpoint
    aws_profile        = data.terraform_remote_state.infra.outputs.aws_profile
    database_name      = data.terraform_remote_state.infra.outputs.database_name
    region             = data.terraform_remote_state.infra.outputs.region
    master_secret_name = data.terraform_remote_state.infra.outputs.master_secret_name
    migrator_username  = data.terraform_remote_state.roles.outputs.migrator_username
  })
  hcl = local.desired_hcl

  depends_on = [data.terraform_remote_state.roles]
}

output "schema_resource_id" {
  value = atlas_schema.app.id
}
