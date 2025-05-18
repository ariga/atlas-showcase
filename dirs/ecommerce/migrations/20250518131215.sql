-- Modify "users" table
ALTER TABLE `users` ADD UNIQUE INDEX `country_code_phone_number` (`country_code`, `phone_number`);
