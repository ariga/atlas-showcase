-- Modify "products" table
ALTER TABLE `products` MODIFY COLUMN `currency_code` char(3) NOT NULL DEFAULT "USD" COMMENT "Currency code for the product price";
