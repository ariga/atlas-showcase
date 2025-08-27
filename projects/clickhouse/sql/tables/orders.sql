-- Orders table in order processing schema
CREATE TABLE order_db.orders
(
    order_id UInt64,
    customer_id UInt64,
    order_date DateTime,
    order_status String,
    currency String,
    subtotal Decimal(18, 2),
    tax_amount Decimal(18, 2),
    shipping_amount Decimal(18, 2),
    discount_amount Decimal(18, 2),
    total_amount Decimal(18, 2),
    payment_method String,
    shipping_address String,
    billing_address String,
    shipping_country String,
    created_at DateTime DEFAULT now(),
    updated_at DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(updated_at)
ORDER BY (order_date, order_id)
PARTITION BY toYYYYMM(order_date)
SETTINGS index_granularity = 8192;
