CREATE TABLE `users` (`id` int NOT NULL, `user_name` varchar(255) NOT NULL, `email` varchar(255) NOT NULL, PRIMARY KEY (`id`)) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

CREATE TABLE `posts` (`id` int NOT NULL, `user_id` int NOT NULL, `title` varchar(255) NOT NULL, `body` text NOT NULL, PRIMARY KEY (`id`), INDEX `user_id` (`user_id`), CONSTRAINT `posts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

CREATE TABLE `categories` (
  `id` int NOT NULL,
  `category_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

CREATE TABLE `products` (
  `id` int NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `description` text,
  `price` decimal(10,2) NOT NULL,
  `category_id` int,
  PRIMARY KEY (`id`),
  INDEX `category_id` (`category_id`),
  CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
