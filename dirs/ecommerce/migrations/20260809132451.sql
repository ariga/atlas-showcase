-- Modify "products" table
ALTER TABLE `products` ADD INDEX `products_manufacturer_status` (`manufacturer`, `status`);
