-- Modify "users" table
ALTER TABLE `users` ADD UNIQUE INDEX `phone_number` (`phone_number`);
