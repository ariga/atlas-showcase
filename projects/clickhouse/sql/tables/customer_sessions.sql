-- Customer sessions tracking table
CREATE TABLE customer_db.customer_sessions
(
    session_id String,
    customer_id Nullable(UInt64),
    session_start DateTime,
    session_end Nullable(DateTime),
    ip_address String,
    user_agent String,
    device_type Enum8('desktop' = 1, 'mobile' = 2, 'tablet' = 3),
    browser String,
    country_code String,
    page_views UInt32 DEFAULT 0,
    duration_seconds UInt32 DEFAULT 0,
    created_at DateTime DEFAULT now()
)
ENGINE = MergeTree()
ORDER BY (session_start, session_id)
PARTITION BY toYYYYMM(session_start)
SETTINGS index_granularity = 8192;
