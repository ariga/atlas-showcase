-- Modify "products" table
ALTER TABLE `products` ADD INDEX `products_manufacturer_price` (`manufacturer`, `price`);
