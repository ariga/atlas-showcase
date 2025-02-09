-- Modify "users" table
ALTER TABLE `users` ADD CONSTRAINT `users_chk_4` CHECK ((`phone_verified` = 0) or ((`phone_number` is not null) and regexp_like(`phone_number`,_utf8mb4'^[0-9]{1,15}$')));
