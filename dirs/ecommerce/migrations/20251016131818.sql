-- Modify "users" table
ALTER TABLE `users` MODIFY COLUMN `date_of_birth` datetime NOT NULL DEFAULT "1900-01-01 00:00:00" COMMENT "Date of birth of the user";
