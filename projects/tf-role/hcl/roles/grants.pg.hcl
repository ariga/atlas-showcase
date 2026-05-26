schema "public" {}

permission {
  to         = user.atlas_migrator
  for        = schema.public
  privileges = [CREATE, USAGE]
}

permission {
  to         = PUBLIC
  for        = schema.public
  privileges = [USAGE]
}
