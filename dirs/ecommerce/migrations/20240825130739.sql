-- Modify "categories" table
ALTER TABLE `categories` ADD COLUMN `category_code` varchar(100) NOT NULL, ADD UNIQUE INDEX `category_code` (`category_code`);
