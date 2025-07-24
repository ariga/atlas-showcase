-- Modify "products" table
ALTER TABLE `products` ADD CONSTRAINT `products_chk_4` CHECK (`price` >= 0);
