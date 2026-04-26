-- Modify "orders" table
ALTER TABLE `orders` DROP INDEX `order_reference`;
-- Modify "orders" table
ALTER TABLE `orders` ADD UNIQUE INDEX `order_reference` (`order_reference`);
