-- Modify "users" table
ALTER TABLE `users` ADD CONSTRAINT `users_chk_2` CHECK (regexp_like(`phone_number`,_utf8mb4'^[0-9]{1,15}$'));
