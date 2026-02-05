-- Modify "orders" table
ALTER TABLE `orders` ADD CONSTRAINT `orders_chk_2` CHECK (`shipping_cost` >= 0);
