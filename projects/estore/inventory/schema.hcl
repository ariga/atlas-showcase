table "categories" {
  schema = schema.default
  column "category_id" {
    null           = false
    type           = int
    auto_increment = true
  }
  column "name" {
    null = false
    type = varchar(255)
  }
  column "description" {
    null = true
    type = text
  }
  primary_key {
    columns = [column.category_id]
  }
}
table "products" {
  schema = schema.default
  column "product_id" {
    null           = false
    type           = int
    auto_increment = true
  }
  column "name" {
    null = false
    type = varchar(255)
  }
  column "category_id" {
    null = true
    type = int
  }
  column "supplier_id" {
    null = true
    type = int
  }
  column "price" {
    null     = false
    type     = decimal(10,2)
    unsigned = false
  }
  column "description" {
    null = true
    type = text
  }
  primary_key {
    columns = [column.product_id]
  }
  foreign_key "products_ibfk_1" {
    columns     = [column.category_id]
    ref_columns = [table.categories.column.category_id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  foreign_key "products_ibfk_2" {
    columns     = [column.supplier_id]
    ref_columns = [table.suppliers.column.supplier_id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  index "category_id" {
    columns = [column.category_id]
  }
  index "supplier_id" {
    columns = [column.supplier_id]
  }
}
table "regions" {
  schema = schema.default
  column "region_id" {
    null           = false
    type           = int
    auto_increment = true
  }
  column "name" {
    null = false
    type = varchar(255)
  }
  primary_key {
    columns = [column.region_id]
  }
}
table "suppliers" {
  schema = schema.default
  column "supplier_id" {
    null           = false
    type           = int
    auto_increment = true
  }
  column "name" {
    null = false
    type = varchar(255)
  }
  column "contact_info" {
    null = true
    type = text
  }
  primary_key {
    columns = [column.supplier_id]
  }
}
table "warehouses" {
  schema = schema.default
  column "warehouse_id" {
    null           = false
    type           = int
    auto_increment = true
  }
  column "name" {
    null = false
    type = varchar(255)
  }
  column "address" {
    null = false
    type = text
  }
  column "region_id" {
    null = true
    type = int
  }
  primary_key {
    columns = [column.warehouse_id]
  }
  foreign_key "warehouses_ibfk_1" {
    columns     = [column.region_id]
    ref_columns = [table.regions.column.region_id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  index "region_id" {
    columns = [column.region_id]
  }
}

view "price_avgs" {
  schema = schema.default
  column "category_name" {
    type = text
  }
  column "avg_price" {
    type = int
  }
  as = <<-SQL
      SELECT categories.name category_name, AVG(products.price) avg_price
      FROM categories JOIN products ON categories.category_id = products.category_id
      GROUP BY categories.name
  SQL
}

schema "default" {
  charset = "utf8mb4"
  collate = "utf8mb4_0900_ai_ci"
}
