-- Modify "payment_methods" table
ALTER TABLE `payment_methods` ADD COLUMN `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT "Timestamp of when the payment method was added";
