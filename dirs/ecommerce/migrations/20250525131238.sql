-- Modify "users" table
ALTER TABLE `users` MODIFY COLUMN `profile_banner_url` varchar(255) NULL DEFAULT "N/A" COMMENT "URL to the user profile banner image";
