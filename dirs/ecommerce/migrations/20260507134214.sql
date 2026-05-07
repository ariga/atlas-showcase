-- Modify "users" table
ALTER TABLE `users` ADD INDEX `users_country_code_phone_number_lookup` (`country_code`, `phone_number`);
