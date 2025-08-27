-- Products table in product catalog schema
CREATE TABLE product_db.products
(
    product_id UInt64,
    sku String,
    name String,
    description String,
    category_id UInt32,
    brand String,
    price Decimal(10, 2),
    cost Decimal(10, 2),
    weight_kg Decimal(8, 3),
    dimensions_cm Array(UInt16),
    status Enum8('active' = 1, 'inactive' = 2, 'discontinued' = 3),
    created_at DateTime,
    updated_at DateTime
)
ENGINE = MergeTree()
ORDER BY (category_id, product_id)
PARTITION BY toYYYYMM(created_at)
SETTINGS index_granularity = 8192;