-- Modify "orders" table
ALTER TABLE `orders` ADD COLUMN `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, ADD COLUMN `updated_at` timestamp NULL ON UPDATE CURRENT_TIMESTAMP;
