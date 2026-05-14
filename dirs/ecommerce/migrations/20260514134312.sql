-- Modify "users" table
ALTER TABLE `users` ADD CONSTRAINT `users_chk_6` CHECK ((`deleted_at` is null) or (`active` = 0));
