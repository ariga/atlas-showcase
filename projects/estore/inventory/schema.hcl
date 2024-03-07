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
table "inventory_by_region" {
  schema = schema.default
  column "region_id" {
    null = false
    type = int
  }
  column "product_id" {
    null = false
    type = int
  }
  column "total_quantity" {
    null = true
    type = int
  }
  primary_key {
    columns = [column.region_id, column.product_id]
  }
  foreign_key "inventory_by_region_ibfk_1" {
    columns     = [column.region_id]
    ref_columns = [table.regions.column.region_id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  foreign_key "inventory_by_region_ibfk_2" {
    columns     = [column.product_id]
    ref_columns = [table.products.column.product_id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  index "product_id" {
    columns = [column.product_id]
  }
}
table "inventory_items" {
  schema = schema.default
  column "inventory_id" {
    null           = false
    type           = int
    auto_increment = true
  }
  column "product_id" {
    null = true
    type = int
  }
  column "warehouse_id" {
    null = true
    type = int
  }
  column "quantity" {
    null    = true
    type    = int
    default = 0
  }
  primary_key {
    columns = [column.inventory_id]
  }
  foreign_key "inventory_items_ibfk_1" {
    columns     = [column.product_id]
    ref_columns = [table.products.column.product_id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  foreign_key "inventory_items_ibfk_2" {
    columns     = [column.warehouse_id]
    ref_columns = [table.warehouses.column.warehouse_id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  index "product_id" {
    columns = [column.product_id]
  }
  index "warehouse_id" {
    columns = [column.warehouse_id]
  }
}
table "orders" {
  schema = schema.default
  column "order_id" {
    null           = false
    type           = int
    auto_increment = true
  }
  column "product_id" {
    null = true
    type = int
  }
  column "quantity" {
    null = false
    type = int
  }
  column "order_date" {
    null    = true
    type    = timestamp
    default = sql("CURRENT_TIMESTAMP")
  }
  column "customer_info" {
    null = true
    type = text
  }
  column "status" {
    null = true
    type = varchar(100)
  }
  primary_key {
    columns = [column.order_id]
  }
  foreign_key "orders_ibfk_1" {
    columns     = [column.product_id]
    ref_columns = [table.products.column.product_id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  index "product_id" {
    columns = [column.product_id]
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
table "shipments" {
  schema = schema.default
  column "shipment_id" {
    null           = false
    type           = int
    auto_increment = true
  }
  column "product_id" {
    null = true
    type = int
  }
  column "warehouse_id" {
    null = true
    type = int
  }
  column "quantity" {
    null = false
    type = int
  }
  column "shipment_date" {
    null    = true
    type    = timestamp
    default = sql("CURRENT_TIMESTAMP")
  }
  primary_key {
    columns = [column.shipment_id]
  }
  foreign_key "shipments_ibfk_1" {
    columns     = [column.product_id]
    ref_columns = [table.products.column.product_id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  foreign_key "shipments_ibfk_2" {
    columns     = [column.warehouse_id]
    ref_columns = [table.warehouses.column.warehouse_id]
    on_update   = NO_ACTION
    on_delete   = NO_ACTION
  }
  index "product_id" {
    columns = [column.product_id]
  }
  index "warehouse_id" {
    columns = [column.warehouse_id]
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
trigger "after_order_insert" {
  on = table.orders
  after {
    insert = true
  }
  as = <<-SQL
  BEGIN
      DECLARE regionId INT;

      SELECT w.region_id INTO regionId
      FROM warehouses w
      JOIN inventory_items ii ON w.warehouse_id = ii.warehouse_id
      WHERE ii.product_id = NEW.product_id
      LIMIT 1; -- This is a simplification and might need adjustment.
  
      UPDATE inventory_by_region
      SET total_quantity = total_quantity - NEW.quantity
      WHERE region_id = regionId AND product_id = NEW.product_id;
  END
  SQL
}
trigger "after_shipment_insert" {
  on = table.shipments
  after {
    insert = true
  }
  as = <<-SQL
  BEGIN
      DECLARE regionId INT;
  
      SELECT region_id INTO regionId FROM warehouses WHERE warehouse_id = NEW.warehouse_id;
  
      INSERT INTO inventory_by_region (region_id, product_id, total_quantity)
      VALUES (regionId, NEW.product_id, NEW.quantity)
      ON DUPLICATE KEY UPDATE total_quantity = total_quantity + NEW.quantity;
  END
  SQL
}
schema "default" {
  charset = "utf8mb4"
  collate = "utf8mb4_0900_ai_ci"
}
