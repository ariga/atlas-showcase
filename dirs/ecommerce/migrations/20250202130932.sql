-- Modify "product_reviews" table
ALTER TABLE `product_reviews` MODIFY COLUMN `rating` int NOT NULL DEFAULT 3 COMMENT "Rating given by the user (1 to 5)";
