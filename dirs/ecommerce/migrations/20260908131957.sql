-- Modify "order_items" table
ALTER TABLE `order_items` ADD CONSTRAINT `order_items_chk_2` CHECK (`price` >= 0);
