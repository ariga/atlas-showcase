-- Modify "users" table
ALTER TABLE `users` ADD COLUMN `gender` enum('male','female','other') NULL COMMENT "User gender";
