-- Modify "products" table
ALTER TABLE `products` ADD COLUMN `tax_percentage` decimal(5,2) NOT NULL DEFAULT 0.00 COMMENT "Applicable sales tax percentage for the product";
