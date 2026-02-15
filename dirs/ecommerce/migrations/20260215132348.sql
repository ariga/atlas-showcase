-- Modify "orders" table
ALTER TABLE `orders` DROP INDEX `order_reference`;
-- Modify "orders" table
ALTER TABLE `orders` ADD INDEX `order_reference` ((ifnull(`order_reference`,_utf8mb4'')));
