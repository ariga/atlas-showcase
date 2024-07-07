-- Modify "users" table
ALTER TABLE `users` DROP COLUMN `user_name`, ADD COLUMN `username` varchar(255) NOT NULL;
