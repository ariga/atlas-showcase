-- Product suppliers management
CREATE TABLE product_db.suppliers (
    supplier_id UInt32,
    supplier_name String,
    contact_person String,
    email String,
    phone String,
    address String,
    city String,
    country_code FixedString(2),
    tax_id String,
    payment_terms String,
    quality_rating UInt8,
    is_active UInt8 DEFAULT 1,
    created_at DateTime DEFAULT now(),
    updated_at DateTime DEFAULT now()
) ENGINE = MergeTree()
ORDER BY supplier_id
PARTITION BY toYYYYMM(created_at);
