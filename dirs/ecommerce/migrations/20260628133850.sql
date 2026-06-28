-- Modify "orders" table
ALTER TABLE `orders` ADD INDEX `orders_user_id_fulfillment_center_id_created_at` (`user_id`, `fulfillment_center_id`, `created_at`);
