-- Modify "categories" table
ALTER TABLE `categories` ADD COLUMN `status` enum('active','inactive') NOT NULL DEFAULT "active" COMMENT "Current status of the category";
-- Modify "users" table
ALTER TABLE `users` MODIFY COLUMN `last_order_date` date NULL COMMENT "Date of the users last order";
