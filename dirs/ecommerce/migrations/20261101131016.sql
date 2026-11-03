-- Modify "orders" table
ALTER TABLE `orders` ADD CONSTRAINT `orders_chk_10` CHECK (char_length(trim(`shipping_method`)) between 1 and 50);
