-- Modify "categories" table
ALTER TABLE `categories` ADD COLUMN `created_by_user` int NOT NULL COMMENT "User ID of the creator of the category", ADD INDEX `categories_ibfk_1` (`created_by_user`), ADD CONSTRAINT `categories_ibfk_1` FOREIGN KEY (`created_by_user`) REFERENCES `users` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE;
