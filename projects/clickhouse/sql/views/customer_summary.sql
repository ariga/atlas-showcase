-- Customer summary view
CREATE VIEW analytics_db.customer_summary AS
SELECT 
    c.customer_id,
    c.email,
    c.first_name,
    c.last_name,
    c.country_code,
    c.registration_date,
    c.customer_segment,
    c.lifetime_value,
    count(o.order_id) as total_orders,
    sum(o.total_amount) as total_spent,
    max(o.order_date) as last_order_date
FROM customer_db.customers c
LEFT JOIN order_db.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.email, c.first_name, c.last_name, c.country_code, 
         c.registration_date, c.customer_segment, c.lifetime_value;
