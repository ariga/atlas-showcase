-- Modify "products" table
ALTER TABLE `products` ADD INDEX `products_category_id_status` (`category_id`, `status`);
