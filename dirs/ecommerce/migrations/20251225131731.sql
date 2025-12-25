-- Modify "orders" table
ALTER TABLE `orders` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Timestamp of the last update to the order record";
