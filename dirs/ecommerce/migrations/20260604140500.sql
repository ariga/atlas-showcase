-- Modify "inventory" table
ALTER TABLE `inventory` ADD INDEX `inventory_product_id_fulfillment_center_id` (`product_id`, `fulfillment_center_id`);
