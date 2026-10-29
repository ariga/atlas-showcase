-- Modify "products" table
ALTER TABLE `products` ADD INDEX `products_category_id_status_price` (`category_id`, `status`, `price`);
