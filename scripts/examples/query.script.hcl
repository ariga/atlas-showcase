variable "email" {
  type = string
}

script "query" "all_users" {
  query "all" {
    sql    = "SELECT id, email FROM users ORDER BY id"
    format = CSV
  }
}

script "query" "get_user" {
  query "user" {
    sql    = "SELECT id, name, address FROM users WHERE email = ?"
    args   = [var.email]
    format = CSV
  }
}

script "query" "customer_export" {
  query "rows" {
    sql    = "SELECT id, email, card FROM customers ORDER BY id"
    format = CSV
    mask {
      columns = ["email"]
      method  = HASH
      salt    = "prod-secret"
    }
    mask {
      columns    = ["card"]
      method     = PARTIAL
      keep_right = 4
    }
  }
}
