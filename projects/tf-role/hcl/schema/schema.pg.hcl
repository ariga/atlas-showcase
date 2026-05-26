schema "public" {}

table "t1" {
  schema = schema.public

  column "id" {
    null = false
    type = integer
  }

  column "created_at" {
    null    = false
    type    = timestamptz
    default = sql("now()")
  }

  primary_key {
    columns = [column.id]
  }
}
