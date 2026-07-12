-- Modify "orders" table
ALTER TABLE `orders` ADD INDEX `orders_user_id_order_status_created_at_history` (`user_id`, `order_status`, `created_at`);
