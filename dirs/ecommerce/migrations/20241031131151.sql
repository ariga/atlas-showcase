-- Modify "inventory" table
ALTER TABLE `inventory` MODIFY COLUMN `quantity` int NOT NULL DEFAULT 0 COMMENT "Available quantity of the product in the fulfillment center";
