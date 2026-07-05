-- Modify "orders" table
ALTER TABLE `orders` ADD INDEX `orders_order_reference_created_at` (`order_reference`, `created_at`);
