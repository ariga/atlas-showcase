-- Supplier performance analytics
CREATE VIEW analytics_db.supplier_performance AS
SELECT 
    s.supplier_id,
    s.supplier_name,
    s.country_code,
    s.quality_rating,
    COUNT(DISTINCT ps.product_id) as products_supplied,
    AVG(ps.cost_price) as avg_cost_price,
    AVG(ps.lead_time_days) as avg_lead_time,
    SUM(ps.minimum_order_quantity) as total_min_order_qty,
    COUNT(CASE WHEN ps.is_primary = 1 THEN 1 END) as primary_supplier_count,
    s.is_active
FROM product_db.suppliers s
LEFT JOIN product_db.product_suppliers ps ON s.supplier_id = ps.supplier_id
WHERE s.is_active = 1
GROUP BY s.supplier_id, s.supplier_name, s.country_code, s.quality_rating, s.is_active
ORDER BY avg_lead_time ASC, quality_rating DESC;
