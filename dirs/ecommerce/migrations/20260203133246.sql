-- Modify "orders" table
ALTER TABLE `orders` ADD INDEX `orders_user_id_created_at` (`user_id`, `created_at`);
