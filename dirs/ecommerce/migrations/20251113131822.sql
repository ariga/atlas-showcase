-- Modify "orders" table
ALTER TABLE `orders` MODIFY COLUMN `order_reference` varchar(255) NULL COMMENT "Optional reference number for the order";
