-- atlas:txtar

-- checks/destructive.sql --
-- atlas:assert DS103
SELECT NOT EXISTS (SELECT 1 FROM `users` WHERE `user_name` IS NOT NULL) AS `is_empty`;

-- migration.sql --
-- Modify "users" table
ALTER TABLE `users` DROP COLUMN `user_name`, ADD COLUMN `username` varchar(255) NOT NULL, ADD UNIQUE INDEX `username` (`username`);
