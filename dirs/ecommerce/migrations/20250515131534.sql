-- Modify "products" table
ALTER TABLE `products` ADD COLUMN `tags` varchar(255) NULL COMMENT "Comma-separated tags for the product";
