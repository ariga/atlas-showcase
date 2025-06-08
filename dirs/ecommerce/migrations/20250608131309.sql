-- Modify "orders" table
ALTER TABLE `orders` ADD COLUMN `shipping_method` varchar(50) NOT NULL DEFAULT "standard" COMMENT "Method of shipping for the order";
