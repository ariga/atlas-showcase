-- Modify "users" table
ALTER TABLE `users` MODIFY COLUMN `phone_number` char(15) NOT NULL COMMENT "Phone number of the user, now required (migration fails if existing rows contain NULL)";
