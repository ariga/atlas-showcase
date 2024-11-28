-- Modify "orders" table
ALTER TABLE `orders` ADD COLUMN `is_featured` bool NOT NULL DEFAULT 0 COMMENT "Flag indicating if the order is featured, defaults to false";
