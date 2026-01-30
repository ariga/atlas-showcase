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
  rule "hcl" "error" {
    error = true
    src = [ "error.rule.hcl" ]
  }
  rule "hcl" "warning" {
    src = [ "warning.rule.hcl" ]
  }
}