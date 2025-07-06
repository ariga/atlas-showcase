-- Modify "orders" table
ALTER TABLE `orders` ADD COLUMN `shipping_cost` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT "Shipping cost associated with the order" AFTER `total_amount`;
