-- Modify "categories" table
ALTER TABLE `categories` ADD COLUMN `category_type` enum('standard','premium','exclusive') NOT NULL DEFAULT "standard" COMMENT "Type of category";
