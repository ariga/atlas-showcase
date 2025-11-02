-- Modify "users" table
ALTER TABLE `users` DROP CHECK `users_chk_1`, ADD CONSTRAINT `users_chk_1` CHECK (regexp_like(`email_address`,_utf8mb4'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$')), MODIFY COLUMN `email_address` varchar(255) NOT NULL COMMENT "Email address of the user, now stored case-insensitively" COLLATE utf8mb4_0900_as_ci;
