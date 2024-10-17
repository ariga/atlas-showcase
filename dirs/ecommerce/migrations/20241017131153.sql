-- Modify "users" table
ALTER TABLE `users` ADD COLUMN `country_code` varchar(5) NOT NULL DEFAULT "+1";
