-- Modify "users" table
ALTER TABLE `users` ADD COLUMN `email_verified` bool NOT NULL DEFAULT 0 COMMENT "Flag indicating if the user email address is verified, defaults to false";
