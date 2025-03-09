-- Modify "users" table
ALTER TABLE `users` MODIFY COLUMN `date_of_birth` date NOT NULL DEFAULT "1900-01-01" COMMENT "Date of birth of the user";
