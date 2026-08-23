-- Modify "products" table
ALTER TABLE `products` ADD INDEX `products_category_id_price` (`category_id`, `price`);
