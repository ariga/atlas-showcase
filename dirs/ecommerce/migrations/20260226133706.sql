-- Modify "order_items" table
ALTER TABLE `order_items` ADD CONSTRAINT `order_items_chk_1` CHECK (`quantity` >= 1);
