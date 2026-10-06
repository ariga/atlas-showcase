-- Modify "order_items" table
ALTER TABLE `order_items` MODIFY COLUMN `id` int NOT NULL AUTO_INCREMENT COMMENT "Unique identifier for each order item", DROP PRIMARY KEY, ADD PRIMARY KEY (`id`), ADD INDEX `order_id` (`order_id`), ADD UNIQUE INDEX `order_items_order_id_product_id` (`order_id`, `product_id`);
