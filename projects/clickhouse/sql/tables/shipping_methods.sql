-- Shipping methods table
CREATE TABLE order_db.shipping_methods
(
    shipping_method_id UInt32,
    method_name String,
    carrier String,
    delivery_time_days UInt8,
    base_cost Decimal(10, 2),
    cost_per_kg Decimal(8, 4),
    max_weight_kg UInt32,
    is_active UInt8 DEFAULT 1,
    created_at DateTime DEFAULT now()
)
ENGINE = MergeTree()
ORDER BY shipping_method_id
SETTINGS index_granularity = 8192;
