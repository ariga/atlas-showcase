-- Product pricing history table
CREATE TABLE product_db.price_history
(
    price_history_id UInt64,
    product_id UInt64,
    old_price Decimal(18, 2),
    new_price Decimal(18, 2),
    change_reason String,
    effective_date DateTime,
    changed_by String,
    created_at DateTime DEFAULT now()
)
ENGINE = MergeTree()
ORDER BY (product_id, effective_date)
PARTITION BY toYYYYMM(effective_date)
SETTINGS index_granularity = 8192;
