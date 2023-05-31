-- Modify "product_reviews" table
ALTER TABLE `product_reviews` MODIFY COLUMN `review_text` text NOT NULL;
-- Modify "products" table
ALTER TABLE `products` ADD UNIQUE INDEX `product_name` (`product_name`);
