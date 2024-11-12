-- Modify "users" table
ALTER TABLE `users` DROP CHECK `users_chk_1`, ADD CONSTRAINT `users_chk_1` CHECK (regexp_like(`email_address`,_utf8mb4'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$')), DROP COLUMN `email`, ADD COLUMN `email_address` varchar(255) NOT NULL, ADD UNIQUE INDEX `email_address` (`email_address`);
