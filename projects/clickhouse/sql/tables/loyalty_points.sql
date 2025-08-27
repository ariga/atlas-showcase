-- Customer loyalty program
CREATE TABLE customer_db.loyalty_points (
    transaction_id UInt32,
    customer_id UInt32,
    order_id UInt32,
    points_earned Int32,
    points_redeemed Int32,
    transaction_type Enum8('earned' = 1, 'redeemed' = 2, 'expired' = 3, 'adjustment' = 4),
    expiry_date DateTime,
    description String,
    created_at DateTime DEFAULT now()
) ENGINE = MergeTree()
ORDER BY (customer_id, created_at)
PARTITION BY toYYYYMM(created_at);
