-- Modify "orders" table
ALTER TABLE `orders` DROP CHECK `orders_chk_7`, ADD CONSTRAINT `orders_chk_7` CHECK ((`order_reference` is not null) and (char_length(trim(`order_reference`)) > 0)), DROP CONSTRAINT `orders_chk_8`, DROP COLUMN `status`;
