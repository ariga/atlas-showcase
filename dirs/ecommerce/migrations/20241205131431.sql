-- Modify "users" table
ALTER TABLE `users` DROP COLUMN `user_name`, ADD COLUMN `username` varchar(255) NOT NULL COMMENT "The username of the user, must be unique", ADD UNIQUE INDEX `username` (`username`);
