-- Modify "orders" table
ALTER TABLE `orders` ADD CONSTRAINT `orders_chk_1` CHECK (`total_amount` >= 0);
