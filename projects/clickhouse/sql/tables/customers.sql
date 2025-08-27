-- Customers table
CREATE TABLE customer_db.customers
(
    customer_id UInt64,
    email String,
    first_name String,
    last_name String,
    phone String,
    date_of_birth Date,
    country_code String,
    city String,
    postal_code String,
    registration_date DateTime,
    last_login DateTime,
    is_active UInt8 DEFAULT 1,
    customer_segment String,
    lifetime_value Decimal(18, 2) DEFAULT 0,
    created_at DateTime DEFAULT now(),
    updated_at DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(updated_at)
ORDER BY customer_id
SETTINGS index_granularity = 8192;
