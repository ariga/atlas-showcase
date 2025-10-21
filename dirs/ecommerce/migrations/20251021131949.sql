-- Modify "products" table
ALTER TABLE `products` MODIFY COLUMN `discount` decimal(6,2) NOT NULL DEFAULT 0.00 COMMENT "Discount amount on the product";
