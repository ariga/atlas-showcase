-- Modify "product_reviews" table
ALTER TABLE `product_reviews` ADD COLUMN `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP;
