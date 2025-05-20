-- Modify "users" table
ALTER TABLE `users` ADD COLUMN `phone_number_verified_at` timestamp NULL COMMENT "Timestamp of when the user phone number was verified";
