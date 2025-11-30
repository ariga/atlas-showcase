-- Modify "products" table
ALTER TABLE `products` MODIFY COLUMN `currency_code` char(3) NULL DEFAULT "" COMMENT "Currency code for the product price, can be NULL, empty by default";
-- Modify "users" table
ALTER TABLE `users` DROP CHECK `users_chk_1`, ADD CONSTRAINT `users_chk_1` CHECK (regexp_like(`email_address`,_utf8mb4'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+x{2,}$'));
