-- Modify "users" table
ALTER TABLE `users` DROP CHECK `users_chk_2`, ADD CONSTRAINT `users_chk_2` CHECK (regexp_like(`phone_number`,_utf8mb4'^[0-9]{1,15}$') or (`phone_number` is null)), MODIFY COLUMN `phone_number` varchar(15) NULL COMMENT "Phone number of the user, now allowed to be NULL";
