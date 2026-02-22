-- Modify "products" table
ALTER TABLE `products` ADD INDEX `products_status_category_id` (`status`, `category_id`);
