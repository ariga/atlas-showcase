-- Modify "orders" table
ALTER TABLE `orders` ADD COLUMN `order_status` enum('pending','shipped','delivered','cancelled','returned') NOT NULL DEFAULT "pending" COMMENT "Status of the order";
