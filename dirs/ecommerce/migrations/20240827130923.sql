-- Modify "payment_methods" table
ALTER TABLE `payment_methods` ADD COLUMN `updated_at` timestamp NULL ON UPDATE CURRENT_TIMESTAMP;
