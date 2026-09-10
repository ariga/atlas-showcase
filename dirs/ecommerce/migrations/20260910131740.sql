-- Modify "users" table
ALTER TABLE `users` DROP COLUMN `user_name`, ADD COLUMN `username` varchar(255) NOT NULL COMMENT "The username of the user, must be unique" COLLATE utf8mb4_0900_as_ci AFTER `id`, DROP INDEX `user_name_email_address`, ADD UNIQUE INDEX `username` (`username`), ADD UNIQUE INDEX `username_email_address` (`username`, `email_address`);
