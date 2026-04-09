-- Modify "users" table
ALTER TABLE `users` MODIFY COLUMN `phone_number_verified_at` timestamp NULL COMMENT "Timestamp of when the user phone number was verified";
