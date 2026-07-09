-- Modify "orders" table
ALTER TABLE `orders` ADD CONSTRAINT `orders_chk_4` CHECK (`total_amount` >= `shipping_cost`);
