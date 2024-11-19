-- Modify "products" table
ALTER TABLE `products` ADD CONSTRAINT `products_chk_1` CHECK (`discount` between 0.00 and 100.00);
