-- Modify "orders" table
ALTER TABLE `orders` ADD INDEX `orders_user_id_created_at_history` (`user_id`, `created_at`);
