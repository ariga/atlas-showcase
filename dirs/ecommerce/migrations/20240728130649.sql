-- Modify "comments" table
ALTER TABLE `comments` DROP FOREIGN KEY `comments_ibfk_1`, DROP FOREIGN KEY `comments_ibfk_2`;
-- Drop "comments" table
DROP TABLE `comments`;
