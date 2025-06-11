data "external_schema" "gorm" {
  program = [
    "go",
    "run",
    "-mod=mod",
    "ariga.io/atlas-provider-gorm",
    "load",
    "--path", ".",
    "--dialect", "sqlite"
  ]
}

env "gorm" {
  url = data.external_schema.gorm.url
  dev = "sqlite://?mode=memory&_fk=1"
}

lint {
  rule "hcl" "name" {
    src = [ "atlas.rule.hcl" ]
  }
}