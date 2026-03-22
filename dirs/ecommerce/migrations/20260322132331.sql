-- Modify "orders" table
ALTER TABLE `orders` ADD INDEX `orders_order_status_created_at` (`order_status`, `created_at`);
