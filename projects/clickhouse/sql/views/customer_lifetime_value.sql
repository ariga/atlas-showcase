-- Customer lifetime value view
CREATE VIEW analytics_db.customer_lifetime_value AS
SELECT 
    c.customer_id,
    c.email,
    c.first_name,
    c.last_name,
    c.registration_date,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(o.total_amount) as total_spent,
    AVG(o.total_amount) as avg_order_value,
    MIN(o.order_date) as first_order_date,
    MAX(o.order_date) as last_order_date,
    dateDiff('day', MIN(o.order_date), MAX(o.order_date)) as customer_lifespan_days,
    CASE 
        WHEN COUNT(DISTINCT o.order_id) >= 10 THEN 'VIP'
        WHEN COUNT(DISTINCT o.order_id) >= 5 THEN 'LOYAL'
        WHEN COUNT(DISTINCT o.order_id) >= 2 THEN 'REPEAT'
        ELSE 'NEW'
    END as customer_segment
FROM customer_db.customers c
LEFT JOIN order_db.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.email, c.first_name, c.last_name, c.registration_date
ORDER BY total_spent DESC;
