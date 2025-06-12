predicate "table" "in" {
  variable "names" {
    type = list(string)
  }
  name {
    in = var.names
  }
}

predicate "column" "not_id" {
  name {
    ne = "id"
  }
}

predicate "index_part" "not_id" {
  column {
    predicate = predicate.column.not_id
  }
}

predicate "index" "single_non_id_unique" {
  and {
    unique {
      eq = true
    }
    count {
      part {
        condition = true
      }
      eq = 1
    }
    all {
      part {
        predicate = predicate.index_part.not_id
      }
    }
  }
}

predicate "table" "has_unique_non_id_column" {
  exists {
    index {
      predicate = predicate.index.single_non_id_unique
    }
  }
}

rule "schema" "unique-non-id-column" {
  description = "Tables must have a unique non-id column"
  table {
    match {
      predicate = predicate.table.in
      vars = {
        names = ["universities", "departments", "students"]
      }
    }
    assert {
      predicate = predicate.table.has_unique_non_id_column
      message   = "Table ${self.name} must have a unique non-id column"
    }
  }
}

predicate "column" "not_nullable" {
  null {
    ne = true
  }
}

predicate "foreign_key" "not_nullable" {
  all {
    column {
      predicate = predicate.column.not_nullable
    }
  }
}

rule "schema" "foreign-key-not-nullable" {
  description = "Foreign keys must not be nullable"
  table {
    match {
      predicate = predicate.table.in
      vars = {
        names = ["departments"]
      }
    }
    foreign_key {
      assert {
        predicate = predicate.foreign_key.not_nullable
        message   = "Foreign key ${self.name} must not be nullable"
      }
    }
  }
}

predicate "column" "postfix_id" {
  name {
    match = ".+Id$"
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
  description = "Foreign keys must have a column name ending with '_id'"
  table {
    match {
      predicate = predicate.table.in
      vars = {
        names = ["departments", "students"]
      }
    }
    foreign_key {
      assert {
        predicate = predicate.foreign_key.postfix_id
        message   = "Foreign key ${self.name} must have a column name ending with 'Id'"
      }
    }
  }
}