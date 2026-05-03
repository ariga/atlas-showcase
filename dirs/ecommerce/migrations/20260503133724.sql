-- Modify "inventory" table
ALTER TABLE `inventory` ADD CONSTRAINT `inventory_chk_2` CHECK (`stock_threshold` >= 0);
