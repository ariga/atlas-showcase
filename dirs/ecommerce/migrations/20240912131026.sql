-- Modify "categories" table
ALTER TABLE `categories` ADD COLUMN `updated_at` timestamp NULL ON UPDATE CURRENT_TIMESTAMP;
