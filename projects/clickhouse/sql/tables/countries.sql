-- Countries reference table for dictionary
CREATE TABLE customer_db.countries (
    country_code String,
    country_name String,
    continent String,
    region String,
    created_at DateTime DEFAULT now()
) ENGINE = MergeTree()
ORDER BY country_code
SETTINGS index_granularity = 8192;
