-- Modify "payment_methods" table
ALTER TABLE `payment_methods` ADD COLUMN `status` varchar(50) NOT NULL DEFAULT "active";
