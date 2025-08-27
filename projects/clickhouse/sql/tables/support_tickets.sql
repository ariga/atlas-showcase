-- Customer support tickets
CREATE TABLE customer_db.support_tickets (
    ticket_id UInt32,
    customer_id UInt32,
    order_id Nullable(UInt32),
    subject String,
    description String,
    priority Enum8('low' = 1, 'medium' = 2, 'high' = 3, 'urgent' = 4),
    status Enum8('open' = 1, 'in_progress' = 2, 'resolved' = 3, 'closed' = 4),
    category String,
    assigned_agent String,
    created_at DateTime DEFAULT now(),
    updated_at DateTime DEFAULT now(),
    resolved_at Nullable(DateTime)
) ENGINE = MergeTree()
ORDER BY (customer_id, created_at)
PARTITION BY toYYYYMM(created_at);
