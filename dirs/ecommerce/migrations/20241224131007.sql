-- Modify "payment_methods" table
ALTER TABLE `payment_methods` MODIFY COLUMN `status` varchar(50) NOT NULL DEFAULT "active" COMMENT "Current status of the payment method, defaults to active";
