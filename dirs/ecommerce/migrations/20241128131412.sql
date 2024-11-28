-- Modify "users" table
ALTER TABLE `users` ADD COLUMN `profile_completed` bool NOT NULL DEFAULT 0 COMMENT "Flag indicating if the user has completed their profile, defaults to false";
