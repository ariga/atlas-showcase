-- Modify "categories" table
ALTER TABLE `categories` ADD COLUMN `category_image_url` varchar(255) NULL COMMENT "URL to an image representing the category" AFTER `category_code`;
