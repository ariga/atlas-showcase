-- Modify "users" table
ALTER TABLE `users` MODIFY COLUMN `gender` enum('male','female','other') NOT NULL DEFAULT "other" COMMENT "User gender";
