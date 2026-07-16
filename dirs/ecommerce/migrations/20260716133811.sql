-- Modify "users" table
ALTER TABLE `users` MODIFY COLUMN `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Timestamp of the last update to the user record";
