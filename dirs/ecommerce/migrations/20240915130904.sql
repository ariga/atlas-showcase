-- Modify "categories" table
ALTER TABLE `categories` ADD COLUMN `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP;
