-- Campaign performance tracking
CREATE TABLE analytics_db.campaign_performance (
    performance_id UInt32,
    campaign_id UInt32,
    date Date,
    impressions UInt32,
    clicks UInt32,
    conversions UInt32,
    cost_amount Decimal(10,2),
    revenue_amount Decimal(12,2),
    channel String,
    device_type Enum8('desktop' = 1, 'mobile' = 2, 'tablet' = 3),
    created_at DateTime DEFAULT now()
) ENGINE = MergeTree()
ORDER BY (campaign_id, date)
PARTITION BY toYYYYMM(date);
