-- Create "comments" table
CREATE TABLE `comments` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `review_id` int NULL,
  `parent_comment_id` int NULL,
  `comment_text` text NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `parent_comment_id` (`parent_comment_id`),
  INDEX `review_id` (`review_id`),
  INDEX `user_id` (`user_id`),
  CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT `comments_ibfk_2` FOREIGN KEY (`review_id`) REFERENCES `product_reviews` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT `comments_ibfk_3` FOREIGN KEY (`parent_comment_id`) REFERENCES `comments` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
