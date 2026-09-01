-- Modify "orders" table
ALTER TABLE `orders` ADD CONSTRAINT `orders_chk_7` CHECK ((`order_reference` is not null) and (char_length(trim(`order_reference`)) > 0));
