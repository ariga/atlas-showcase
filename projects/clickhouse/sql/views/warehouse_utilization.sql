-- Warehouse capacity utilization view
CREATE VIEW analytics_db.warehouse_utilization AS
SELECT 
    w.warehouse_id,
    w.warehouse_name,
    w.city,
    w.country_code,
    w.capacity_cubic_meters,
    COUNT(DISTINCT i.product_id) as products_stored,
    SUM(i.quantity_available) as total_inventory_units,
    SUM(i.quantity_reserved) as total_reserved_units,
    AVG(p.weight_kg * i.quantity_available) as estimated_weight_kg,
    CASE 
        WHEN w.capacity_cubic_meters > 0 THEN 
            (SUM(i.quantity_available) * 100.0) / w.capacity_cubic_meters
        ELSE 0
    END as utilization_percentage
FROM product_db.warehouses w
LEFT JOIN product_db.inventory i ON w.warehouse_id = i.warehouse_id
LEFT JOIN product_db.products p ON i.product_id = p.product_id
WHERE w.is_active = 1
GROUP BY w.warehouse_id, w.warehouse_name, w.city, w.country_code, w.capacity_cubic_meters
ORDER BY utilization_percentage DESC;
