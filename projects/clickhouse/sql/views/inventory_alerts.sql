-- Inventory alerts view for low stock monitoring
CREATE VIEW analytics_db.inventory_alerts AS
SELECT 
    i.product_id,
    p.name as product_name,
    p.sku,
    i.quantity_available,
    i.reorder_level,
    i.reorder_quantity,
    CASE 
        WHEN i.quantity_available <= 0 THEN 'OUT_OF_STOCK'
        WHEN i.quantity_available <= i.reorder_level THEN 'LOW_STOCK'
        ELSE 'ADEQUATE'
    END as stock_status,
    p.status as product_status
FROM product_db.inventory i
INNER JOIN product_db.products p ON i.product_id = p.product_id
WHERE i.quantity_available <= i.reorder_level
ORDER BY i.quantity_available ASC;
