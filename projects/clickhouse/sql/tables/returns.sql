-- Product return requests
CREATE TABLE order_db.returns (
    return_id UInt32,
    order_id UInt32,
    order_item_id UInt32,
    customer_id UInt32,
    product_id UInt32,
    return_reason String,
    return_quantity UInt32,
    return_status Enum8('requested' = 1, 'approved' = 2, 'shipped' = 3, 'received' = 4, 'processed' = 5, 'rejected' = 6),
    refund_amount Decimal(10,2),
    return_date DateTime DEFAULT now(),
    processed_date Nullable(DateTime),
    notes String
) ENGINE = MergeTree()
ORDER BY (customer_id, return_date)
PARTITION BY toYYYYMM(return_date);