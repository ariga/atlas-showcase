-- Modify "posts" table
ALTER TABLE `posts` ADD COLUMN `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT "Timestamp of when the post was created";
