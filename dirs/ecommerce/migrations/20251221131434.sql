-- Modify "users" table
ALTER TABLE `users` DROP CHECK `users_chk_1`, ADD CONSTRAINT `users_chk_1` CHECK (regexp_like(`email_address`,_utf8mb4'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+a-zA-Z]{2,}$')), MODIFY COLUMN `country_code` char(3) NULL DEFAULT "+1" COMMENT "Country code for the phone number, defaults to US and can now be NULL";
