-- Monthly sales summary view
CREATE VIEW analytics_db.monthly_sales AS
SELECT 
    toYYYYMM(o.order_date) as year_month,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    SUM(o.total_amount) as total_revenue,
    AVG(o.total_amount) as avg_order_value,
    SUM(oi.quantity) as total_items_sold
FROM order_db.orders o
LEFT JOIN order_db.order_items oi ON o.order_id = oi.order_id
GROUP BY toYYYYMM(o.order_date)
ORDER BY year_month DESC;
