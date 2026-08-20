-- Modify "orders" table
ALTER TABLE `orders` DROP CHECK `orders_chk_4`, ADD CONSTRAINT `orders_chk_4` CHECK (char_length(trim(`shipping_address`)) between 1 and 255), DROP CHECK `orders_chk_5`, ADD CONSTRAINT `orders_chk_5` CHECK (`total_amount` >= `shipping_cost`), ADD CONSTRAINT `orders_chk_6` CHECK (lower(`status`) = `order_status`);
