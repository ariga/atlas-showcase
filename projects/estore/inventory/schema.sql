CREATE TABLE categories (
                            category_id INT AUTO_INCREMENT PRIMARY KEY,
                            name VARCHAR(255) NOT NULL,
                            description TEXT
);

CREATE TABLE suppliers (
                           supplier_id INT AUTO_INCREMENT PRIMARY KEY,
                           name VARCHAR(255) NOT NULL,
                           contact_info TEXT
);
CREATE TABLE products (
                          product_id INT AUTO_INCREMENT PRIMARY KEY,
                          name VARCHAR(255) NOT NULL,
                          category_id INT,
                          supplier_id INT,
                          price DECIMAL(10, 2) NOT NULL,
                          description TEXT,
                          FOREIGN KEY (category_id) REFERENCES categories(category_id),
                          FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

CREATE TABLE regions (
                         region_id INT AUTO_INCREMENT PRIMARY KEY,
                         name VARCHAR(255) NOT NULL
);

CREATE TABLE warehouses (
                            warehouse_id INT AUTO_INCREMENT PRIMARY KEY,
                            name VARCHAR(255) NOT NULL,
                            address TEXT NOT NULL,
                            region_id INT,
    -- Add a foreign key for region_id if regions are predefined
    FOREIGN KEY (region_id) REFERENCES regions(region_id)

);

CREATE TABLE inventory_items (
                                 inventory_id INT AUTO_INCREMENT PRIMARY KEY,
                                 product_id INT,
                                 warehouse_id INT,
                                 quantity INT DEFAULT 0,
                                 FOREIGN KEY (product_id) REFERENCES products(product_id),
                                 FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
);

CREATE TABLE orders (
                        order_id INT AUTO_INCREMENT PRIMARY KEY,
                        product_id INT,
                        quantity INT NOT NULL,
                        order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        customer_info TEXT,
                        status VARCHAR(100),
                        FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE shipments (
                           shipment_id INT AUTO_INCREMENT PRIMARY KEY,
                           product_id INT,
                           warehouse_id INT,
                           quantity INT NOT NULL,
                           shipment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                           FOREIGN KEY (product_id) REFERENCES products(product_id),
                           FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id)
);

CREATE TABLE inventory_by_region (
                                     region_id INT,
                                     product_id INT,
                                     total_quantity INT,
                                     PRIMARY KEY (region_id, product_id),
                                     FOREIGN KEY (region_id) REFERENCES regions(region_id),
                                     FOREIGN KEY (product_id) REFERENCES products(product_id)
);

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
DELIMITER ;

DELIMITER $$
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
