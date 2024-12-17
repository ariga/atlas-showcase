-- Modify "users" table
ALTER TABLE `users` ADD UNIQUE INDEX `user_name_email` (`user_name`, `email`);
