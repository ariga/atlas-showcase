-- Modify "inventory" table
ALTER TABLE `inventory` ADD COLUMN `stock_threshold` int NOT NULL DEFAULT 10 COMMENT "Minimum quantity of the product before restocking is needed";
