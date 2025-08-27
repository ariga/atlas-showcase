-- Payment transactions table
CREATE TABLE order_db.payment_transactions
(
    transaction_id UInt64,
    order_id UInt64,
    payment_method String,
    transaction_type Enum8('payment' = 1, 'refund' = 2, 'partial_refund' = 3),
    amount Decimal(18, 2),
    currency String,
    gateway_reference String,
    gateway_response_code String,
    status Enum8('pending' = 1, 'completed' = 2, 'failed' = 3, 'cancelled' = 4),
    processed_at DateTime,
    created_at DateTime DEFAULT now()
)
ENGINE = MergeTree()
ORDER BY (order_id, transaction_id)
PARTITION BY toYYYYMM(processed_at)
SETTINGS index_granularity = 8192;
