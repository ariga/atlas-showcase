-- Modify "users" table
ALTER TABLE `users` ADD CONSTRAINT `users_chk_3` CHECK ((`last_order_date` is null) or (`last_order_date` >= `created_at`));
