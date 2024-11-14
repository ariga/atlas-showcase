-- Modify "inventory" table
ALTER TABLE `inventory` ADD CONSTRAINT `inventory_chk_1` CHECK (`quantity` >= 0);
