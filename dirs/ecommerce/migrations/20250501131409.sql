-- Modify "products" table
ALTER TABLE `products` ADD CONSTRAINT `products_chk_2` CHECK (`discount` <= `max_discount`), ADD COLUMN `max_discount` decimal(5,2) NOT NULL DEFAULT 20.00 COMMENT "Maximum allowable discount amount for the product";
