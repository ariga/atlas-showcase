-- Modify "orders" table
ALTER TABLE `orders` MODIFY COLUMN `order_status` enum('pending','processing','shipped','delivered','cancelled','returned') NOT NULL DEFAULT "pending" COMMENT "Status of the order";
