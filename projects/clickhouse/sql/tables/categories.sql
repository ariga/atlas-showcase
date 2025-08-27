-- Categories reference table for dictionary
CREATE TABLE product_db.categories (
    category_id UInt32,
    category_name String,
    parent_id UInt32,
    level UInt8,
    path String,
    created_at DateTime DEFAULT now(),
    updated_at DateTime DEFAULT now()
) ENGINE = MergeTree()
ORDER BY category_id
SETTINGS index_granularity = 8192;
