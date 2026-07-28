-- Modify "orders" table
ALTER TABLE `orders` ADD CONSTRAINT `orders_chk_5` CHECK (lower(`status`) = `order_status`);
