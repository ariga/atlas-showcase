-- Modify "products" table
ALTER TABLE `products` ADD INDEX `products_deleted_at` (`deleted_at`);
