-- Modify "orders" table
ALTER TABLE `orders` MODIFY COLUMN `status` enum('PENDING','PROCESSING','SHIPPED','DELIVERED','CANCELLED','RETURNED') NOT NULL DEFAULT "PENDING" COMMENT "Current status of the order";
