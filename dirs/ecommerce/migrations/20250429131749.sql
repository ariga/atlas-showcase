-- Modify "categories" table
ALTER TABLE `categories` ADD COLUMN `created_by` int NOT NULL COMMENT "Foreign key referencing the user who created the category", ADD INDEX `categories_ibfk_1` (`created_by`), ADD CONSTRAINT `categories_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE;
