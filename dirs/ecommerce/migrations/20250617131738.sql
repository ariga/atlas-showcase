-- Modify "products" table
ALTER TABLE `products` ADD CONSTRAINT `products_chk_3` CHECK (`tax_percentage` between 0.00 and 100.00);
