-- Modify "categories" table
ALTER TABLE `categories` ADD UNIQUE INDEX `category_name` (`category_name`);
