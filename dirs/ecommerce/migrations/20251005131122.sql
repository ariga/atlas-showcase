-- Modify "users" table
ALTER TABLE `users` MODIFY COLUMN `country_code` char(3) NOT NULL DEFAULT "+1" COMMENT "Country code for the phone number, defaults to US";
