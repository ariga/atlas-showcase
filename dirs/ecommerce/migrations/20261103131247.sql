-- Modify "inventory" table
ALTER TABLE `inventory` ADD CONSTRAINT `inventory_chk_3` CHECK (`quantity` >= `stock_threshold`);
