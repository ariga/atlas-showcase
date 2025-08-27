-- Product reviews table
CREATE TABLE product_db.product_reviews
(
    review_id UInt64,
    product_id UInt64,
    customer_id UInt64,
    rating UInt8,
    review_title String,
    review_text String,
    is_verified_purchase UInt8 DEFAULT 0,
    helpful_votes UInt32 DEFAULT 0,
    total_votes UInt32 DEFAULT 0,
    review_date DateTime,
    status Enum8('pending' = 1, 'approved' = 2, 'rejected' = 3),
    created_at DateTime DEFAULT now()
)
ENGINE = MergeTree()
ORDER BY (product_id, review_date)
PARTITION BY toYYYYMM(review_date)
SETTINGS index_granularity = 8192;
