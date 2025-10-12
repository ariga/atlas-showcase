-- Modify "categories" table
ALTER TABLE `categories` MODIFY COLUMN `category_code` char(10) NOT NULL COMMENT "Unique code for the category of a fixed length";
