-- Modify "orders" table
ALTER TABLE `orders` ADD CONSTRAINT `orders_chk_10` CHECK (regexp_like(`shipping_method`,_utf8mb4'^[a-z0-9_]+$'));
