-- Modify "users" table
ALTER TABLE `users` ADD CONSTRAINT `users_chk_7` CHECK (char_length(trim(`preferred_language`)) > 0);
