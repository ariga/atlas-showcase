-- Modify "users" table
ALTER TABLE `users` DROP CHECK `users_chk_1`, ADD CONSTRAINT `users_chk_1` CHECK (regexp_like(`email_address`,_utf8mb4'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$')), ADD COLUMN `preferred_language` varchar(10) NOT NULL DEFAULT "en" COMMENT "Preferred language of the user, defaults to English";
