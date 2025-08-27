-- Product performance view for analytics
CREATE VIEW analytics_db.product_performance AS
SELECT 
    p.product_id,
    p.name as product_name,
    p.category_id,
    c.category_name,
    COUNT(oi.order_item_id) as total_orders,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.unit_price * oi.quantity) as total_revenue,
    AVG(oi.unit_price) as avg_selling_price,
    p.cost,
    (AVG(oi.unit_price) - p.cost) as avg_profit_per_unit
FROM product_db.products p
LEFT JOIN product_db.categories c ON p.category_id = c.category_id
LEFT JOIN order_db.order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name, p.category_id, c.category_name, p.cost
ORDER BY total_revenue DESC;
