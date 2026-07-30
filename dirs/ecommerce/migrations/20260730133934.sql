-- Modify "orders" table
ALTER TABLE `orders` ADD INDEX `orders_order_status_created_at_user_id` (`order_status`, `created_at`, `user_id`);
