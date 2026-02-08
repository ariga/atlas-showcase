-- Modify "product_reviews" table
ALTER TABLE `product_reviews` ADD INDEX `product_reviews_order_items_lookup` (`product_id`, `user_id`);
