data "external_schema" "django" {
  program = [
    "python3",
    "manage.py",
    "atlas-provider-django",
    "--dialect", "sqlite"
  ]
}

env "django" {
  url = data.external_schema.django.url
  dev = "sqlite://?mode=memory&_fk=1"
}

lint {
  rule "hcl" "name" {
    src = [ "atlas.rule.hcl" ]
  }
}