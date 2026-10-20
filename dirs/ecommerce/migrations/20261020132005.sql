-- Modify "order_items" table
ALTER TABLE `order_items` ADD CONSTRAINT `order_items_chk_3` CHECK ((`order_reference` is null) or (char_length(trim(`order_reference`)) > 0));
