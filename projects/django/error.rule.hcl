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
        names = ["academie_university", "academie_department", "academie_student"]
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
        names = ["academie_department"]
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