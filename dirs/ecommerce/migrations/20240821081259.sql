-- Modify "products" table
ALTER TABLE `products` ADD COLUMN `discount` decimal(5,2) NOT NULL DEFAULT 0.00;
