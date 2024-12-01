-- Modify "users" table
ALTER TABLE `users` MODIFY COLUMN `user_name` varchar(255) NOT NULL DEFAULT "guest" COMMENT "The username of the user, must be unique";
