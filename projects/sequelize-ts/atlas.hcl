data "external_schema" "sequelize" {
  program = [
    "npx",
    "@ariga/ts-atlas-provider-sequelize",
    "load",
    "--path", "./src/models",
    "--dialect", "sqlite"
  ]
}

env "sequelize" {
  url = data.external_schema.sequelize.url
  dev = "sqlite://?mode=memory&_fk=1"
}

lint {
  rule "hcl" "name" {
    src = [ "atlas.rule.hcl" ]
  }
}