-- Modify "orders" table
ALTER TABLE `orders` ADD INDEX `user_id_order_status` (`user_id`, `order_status`);
