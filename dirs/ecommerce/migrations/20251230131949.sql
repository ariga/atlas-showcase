-- Modify "users" table
ALTER TABLE `users` MODIFY COLUMN `reward_points` bigint unsigned NOT NULL DEFAULT 0 COMMENT "The number of reward points the user has accumulated";
