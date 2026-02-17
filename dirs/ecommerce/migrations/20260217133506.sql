-- Modify "orders" table
ALTER TABLE `orders` ADD INDEX `user_id_order_reference` (`user_id`, `order_reference`);
