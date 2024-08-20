-- Modify "product_reviews" table
ALTER TABLE `product_reviews` ADD UNIQUE INDEX `user_product_review` (`user_id`, `product_id`);
