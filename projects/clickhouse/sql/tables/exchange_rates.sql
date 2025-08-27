-- Exchange rates reference table for dictionary
CREATE TABLE order_db.exchange_rates (
    from_currency String,
    to_currency String,
    exchange_rate Decimal64(8),
    last_updated DateTime DEFAULT now()
) ENGINE = ReplacingMergeTree(last_updated)
ORDER BY (from_currency, to_currency)
SETTINGS index_granularity = 8192;
