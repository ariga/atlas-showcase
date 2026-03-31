-- Modify "orders" table
ALTER TABLE `orders` ADD INDEX `orders_order_reference_user_id` (`order_reference`, `user_id`);
