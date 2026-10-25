-- Modify "users" table
ALTER TABLE `users` ADD CONSTRAINT `users_chk_8` CHECK ((`phone_verified` = 0) or (`phone_number_verified_at` is not null));
