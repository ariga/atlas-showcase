-- Modify "users" table
ALTER TABLE `users` ADD COLUMN `updated_at` timestamp NULL ON UPDATE CURRENT_TIMESTAMP;
