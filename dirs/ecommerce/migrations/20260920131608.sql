-- Modify "order_items" table
ALTER TABLE `order_items` MODIFY COLUMN `price` decimal(12,2) NOT NULL COMMENT "Price of the product at the time of order";
