-- Modify "orders" table
ALTER TABLE `orders` DROP CHECK `orders_chk_3`, ADD CONSTRAINT `orders_chk_3` CHECK (char_length(trim(`order_reference`)) between 1 and 255);
