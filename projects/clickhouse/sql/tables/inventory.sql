-- Inventory tracking table
CREATE TABLE product_db.inventory
(
    product_id UInt64,
    warehouse_id String,
    quantity_available UInt32,
    quantity_reserved UInt32,
    reorder_level UInt32,
    reorder_quantity UInt32,
    last_restocked DateTime,
    created_at DateTime DEFAULT now(),
    updated_at DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(updated_at)
ORDER BY (product_id, warehouse_id)
SETTINGS index_granularity = 8192;
