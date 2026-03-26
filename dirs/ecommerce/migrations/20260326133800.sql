-- Modify "orders" table
ALTER TABLE `orders` ADD INDEX `orders_user_id_fulfillment_center_id` (`user_id`, `fulfillment_center_id`);
