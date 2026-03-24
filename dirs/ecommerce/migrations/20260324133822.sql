-- Modify "orders" table
ALTER TABLE `orders` ADD CONSTRAINT `orders_chk_3` CHECK (char_length(trim(`order_reference`)) > 0);
