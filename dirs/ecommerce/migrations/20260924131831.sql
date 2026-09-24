-- Modify "orders" table
ALTER TABLE `orders` MODIFY COLUMN `total_amount` decimal(12,2) unsigned NOT NULL COMMENT "Total amount for the order";
