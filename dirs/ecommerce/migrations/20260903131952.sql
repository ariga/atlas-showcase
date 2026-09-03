-- Modify "orders" table
ALTER TABLE `orders` ADD INDEX `orders_order_reference_created_at_recent` (`order_reference`, `created_at`);
