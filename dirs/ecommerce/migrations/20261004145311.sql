-- Modify "users" table
ALTER TABLE `users` ADD CONSTRAINT `users_chk_7` CHECK (`preferred_language` = lower(`preferred_language`));
