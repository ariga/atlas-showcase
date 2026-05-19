-- Modify "users" table
ALTER TABLE `users` MODIFY COLUMN `phone_number` char(15) NULL COMMENT "Phone number of the user, now allowed to be NULL";
