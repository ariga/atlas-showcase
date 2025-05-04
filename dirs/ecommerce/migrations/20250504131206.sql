-- Modify "users" table
ALTER TABLE `users` ADD CONSTRAINT `users_chk_5` CHECK (`reward_points` >= 0);
