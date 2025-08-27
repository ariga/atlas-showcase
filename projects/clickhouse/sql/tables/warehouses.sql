-- Warehouse management table
CREATE TABLE product_db.warehouses (
    warehouse_id UInt32,
    warehouse_name String,
    address String,
    city String,
    state_province String,
    postal_code String,
    country_code FixedString(2),
    phone String,
    email String,
    manager_name String,
    capacity_cubic_meters UInt32,
    is_active UInt8 DEFAULT 1,
    created_at DateTime DEFAULT now(),
    updated_at DateTime DEFAULT now()
) ENGINE = MergeTree()
ORDER BY warehouse_id
PARTITION BY toYYYYMM(created_at);
