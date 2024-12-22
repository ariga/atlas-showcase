-- Modify "users" table
ALTER TABLE `users` ADD COLUMN `reward_points` int NOT NULL DEFAULT 0 COMMENT "The number of reward points the user has accumulated";
