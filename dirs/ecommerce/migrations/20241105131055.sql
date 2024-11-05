-- Modify "products" table
ALTER TABLE `products` ADD COLUMN `currency_code` varchar(3) NOT NULL DEFAULT "USD" COMMENT "Currency code for the product price";
