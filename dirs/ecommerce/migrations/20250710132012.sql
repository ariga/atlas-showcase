-- Modify "users" table
ALTER TABLE `users` DROP CHECK `users_chk_5`, ADD CONSTRAINT `users_chk_5` CHECK ((`reward_points` >= 0) and (`reward_points` <= 10000));
