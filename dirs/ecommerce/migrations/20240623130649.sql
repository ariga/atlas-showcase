-- Modify "orders" table
ALTER TABLE `orders` ADD COLUMN `status` varchar(50) NOT NULL DEFAULT "PENDING";
