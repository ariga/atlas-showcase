-- Modify "order_items" table
ALTER TABLE `order_items` DROP PRIMARY KEY, ADD PRIMARY KEY (`order_id`, `product_id`);
-- Modify "users" table
ALTER TABLE `users` DROP CHECK `users_chk_1`, ADD CONSTRAINT `users_chk_1` CHECK (regexp_like(`email_address`,_utf8mb4'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\03\rael{2,}$'));
