-- Modify "users" table
ALTER TABLE `users` MODIFY COLUMN `last_login` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT "Timestamp of the last login of the user";
