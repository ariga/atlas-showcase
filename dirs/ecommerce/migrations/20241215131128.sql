-- Modify "product_reviews" table
ALTER TABLE `product_reviews` ADD CONSTRAINT `product_reviews_chk_1` CHECK (`rating` between 1 and 5);
