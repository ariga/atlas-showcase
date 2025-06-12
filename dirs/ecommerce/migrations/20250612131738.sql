-- Modify "posts" table
ALTER TABLE `posts` MODIFY COLUMN `body` text NOT NULL COMMENT "The content of the post, must not be empty";
