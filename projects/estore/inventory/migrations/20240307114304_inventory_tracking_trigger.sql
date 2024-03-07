DELIMITER $$
CREATE TRIGGER after_shipment_insert
AFTER INSERT ON shipments
FOR EACH ROW
BEGIN
    DECLARE regionId INT;

    SELECT region_id INTO regionId FROM warehouses WHERE warehouse_id = NEW.warehouse_id;

    INSERT INTO inventory_by_region (region_id, product_id, total_quantity)
    VALUES (regionId, NEW.product_id, NEW.quantity)
    ON DUPLICATE KEY UPDATE total_quantity = total_quantity + NEW.quantity;
END$$

CREATE TRIGGER after_order_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    DECLARE regionId INT;

    -- Assuming each product is linked to a single warehouse, which is a simplification.
    -- This might need a more complex logic based on how your warehouses and orders are structured.
    SELECT w.region_id INTO regionId
    FROM warehouses w
    JOIN inventory_items ii ON w.warehouse_id = ii.warehouse_id
    WHERE ii.product_id = NEW.product_id
    LIMIT 1; -- This is a simplification and might need adjustment.

    UPDATE inventory_by_region
    SET total_quantity = total_quantity - NEW.quantity
    WHERE region_id = regionId AND product_id = NEW.product_id;
END$$
DELIMITER ;
