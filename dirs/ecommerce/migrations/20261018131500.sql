-- Modify "orders" table
ALTER TABLE `orders` ADD INDEX `orders_order_reference_created_at_v2` (`order_reference`, `created_at`);
