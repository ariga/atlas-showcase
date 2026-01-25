-- Modify "users" table
ALTER TABLE `users` MODIFY COLUMN `country_code` char(3) NULL DEFAULT "+1" COMMENT "Country code for the phone number, defaults to US and can now be NULL";
