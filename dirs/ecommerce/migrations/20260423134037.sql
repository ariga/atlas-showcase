-- Modify "orders" table
ALTER TABLE `orders` ADD INDEX `orders_fulfillment_center_id_order_status_created_at` (`fulfillment_center_id`, `order_status`, `created_at`);
