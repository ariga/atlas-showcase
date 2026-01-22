-- Modify "orders" table
ALTER TABLE `orders` ADD INDEX `user_id_order_status_created_at` (`user_id`, `order_status`, `created_at`);
