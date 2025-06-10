-- Modify "users" table
ALTER TABLE `users` MODIFY COLUMN `address` varchar(255) NOT NULL COMMENT "Address of the user, now required";
