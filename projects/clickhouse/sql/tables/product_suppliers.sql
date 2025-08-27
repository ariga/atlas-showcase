-- Product supplier relationships table
CREATE TABLE product_db.product_suppliers
(
    product_id UInt64,
    supplier_id UInt32,
    supplier_sku String,
    cost_price Decimal(18, 2),
    minimum_order_quantity UInt32,
    lead_time_days UInt16,
    is_primary UInt8 DEFAULT 0,
    created_at DateTime DEFAULT now()
)
ENGINE = MergeTree()
ORDER BY (product_id, supplier_id)
SETTINGS index_granularity = 8192;
