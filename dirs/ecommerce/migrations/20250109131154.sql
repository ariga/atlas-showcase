-- Modify "users" table
ALTER TABLE `users` DROP INDEX `user_name_email_address`;
-- Modify "users" table
ALTER TABLE `users` DROP CHECK `users_chk_1`, ADD CONSTRAINT `users_chk_1` CHECK (regexp_like(`email`,_utf8mb4'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$')), DROP COLUMN `email_address`, ADD COLUMN `email` varchar(255) NOT NULL, ADD UNIQUE INDEX `user_name_email_address` (`user_name`, `email`), ADD UNIQUE INDEX `email` (`email`);
