-- Modify "posts" table
ALTER TABLE `posts` ADD COLUMN `created_by` int NOT NULL COMMENT "User who originally created the post", ADD INDEX `posts_ibfk_3` (`created_by`), ADD CONSTRAINT `posts_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE;
