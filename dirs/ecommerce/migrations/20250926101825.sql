-- Modify "users" table
ALTER TABLE `users` MODIFY COLUMN `user_name` varchar(255) NOT NULL COMMENT "The username of the user, must be unique" COLLATE utf8mb4_0900_as_ci;
