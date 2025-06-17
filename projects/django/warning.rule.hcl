predicate "column" "postfix_id" {
  name {
    match = ".+_id$"
  }
}

predicate "foreign_key" "postfix_id" {
  all {
    column {
      predicate = predicate.column.postfix_id
    }
  }
}

rule "schema" "foreign-key-postfix-id" {
  description = "Foreign keys should have a column name ending with '_id'"
  table {
    match {
      predicate = predicate.table.in
      vars = {
        names = ["academie_department", "academie_student"]
      }
    }
    foreign_key {
      assert {
        predicate = predicate.foreign_key.postfix_id
        message   = "Foreign key ${self.name} should have a column name ending with '_id'"
      }
    }
  }
}