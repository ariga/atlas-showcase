-- Modify "orders" table
ALTER TABLE `orders` ADD INDEX `fulfillment_center_id_created_at` (`fulfillment_center_id`, `created_at`);
