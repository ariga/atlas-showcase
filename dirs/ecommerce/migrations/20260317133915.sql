-- Modify "users" table
ALTER TABLE `users` MODIFY COLUMN `phone_number` varchar(15) NOT NULL COMMENT "Phone number of the user, now required";
