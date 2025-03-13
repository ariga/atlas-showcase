-- Modify "posts" table
ALTER TABLE `posts` ADD COLUMN `date_archived` timestamp NULL COMMENT "Timestamp of when the post was archived";
