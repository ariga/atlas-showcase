-- Order items table
CREATE TABLE order_db.order_items
(
    order_item_id UInt64,
    order_id UInt64,
    product_id UInt64,
    quantity UInt32,
    unit_price Decimal(18, 2),
    discount_amount Decimal(18, 2),
    line_total Decimal(18, 2),
    created_at DateTime DEFAULT now()
)
ENGINE = MergeTree()
ORDER BY (order_id, order_item_id)
SETTINGS index_granularity = 8192;
