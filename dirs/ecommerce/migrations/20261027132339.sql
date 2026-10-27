-- Modify "orders" table
ALTER TABLE `orders` ADD CONSTRAINT `orders_chk_9` CHECK (`shipping_method` = lower(`shipping_method`));
