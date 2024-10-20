-- Modify "posts" table
ALTER TABLE `posts` ADD COLUMN `last_updated_by` int NULL, ADD INDEX `posts_ibfk_2` (`last_updated_by`), ADD CONSTRAINT `posts_ibfk_2` FOREIGN KEY (`last_updated_by`) REFERENCES `users` (`id`) ON UPDATE NO ACTION ON DELETE SET NULL;
