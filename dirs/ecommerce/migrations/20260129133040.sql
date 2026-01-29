-- Modify "product_reviews" table
ALTER TABLE `product_reviews` ADD INDEX `product_id_user_id` (`product_id`, `user_id`);
