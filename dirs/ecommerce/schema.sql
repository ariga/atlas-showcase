-- Create "users" table
CREATE TABLE `users` (
                         `id` int NOT NULL,
                         `user_name` varchar(255) NOT NULL,
                         `email` varchar(255) NOT NULL,
                         `is_admin` bool NULL DEFAULT 0,
                         `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                         `updated_at` timestamp NULL ON UPDATE CURRENT_TIMESTAMP,
                         `date_of_birth` date NULL,
                         `active` bool NOT NULL DEFAULT 1,
                         PRIMARY KEY (`id`)
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
-- Create "categories" table
CREATE TABLE `categories` (
                              `id` int NOT NULL,
                              `category_name` varchar(255) NOT NULL,
                              PRIMARY KEY (`id`)
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
-- Create "products" table
CREATE TABLE `products` (
                            `id` int NOT NULL,
                            `product_name` varchar(255) NOT NULL,
                            `price` decimal(10,2) NOT NULL,
                            `category_id` int NULL,
                            `description` text NULL,
                            PRIMARY KEY (`id`),
                            INDEX `category_id` (`category_id`),
                            UNIQUE INDEX `product_name` (`product_name`),
                            CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON UPDATE NO ACTION ON DELETE SET NULL
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
-- Create "product_reviews" table
CREATE TABLE `product_reviews` (
                                   `id` int NOT NULL,
                                   `product_id` int NOT NULL,
                                   `user_id` int NOT NULL,
                                   `rating` int NOT NULL,
                                   `review_text` text NOT NULL,
                                   PRIMARY KEY (`id`),
                                   INDEX `product_id` (`product_id`),
                                   INDEX `user_id` (`user_id`),
                                   CONSTRAINT `product_reviews_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE,
                                   CONSTRAINT `product_reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
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
-- Create "fulfillment_centers" table
CREATE TABLE `fulfillment_centers` (
                                       `id` int NOT NULL,
                                       `name` varchar(255) NOT NULL,
                                       `location` varchar(255) NOT NULL,
                                       PRIMARY KEY (`id`)
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
-- Create "inventory" table
CREATE TABLE `inventory` (
                             `id` int NOT NULL,
                             `product_id` int NOT NULL,
                             `fulfillment_center_id` int NOT NULL,
                             `quantity` int NOT NULL,
                             PRIMARY KEY (`id`),
                             INDEX `fulfillment_center_id` (`fulfillment_center_id`),
                             INDEX `product_id` (`product_id`),
                             CONSTRAINT `inventory_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE,
                             CONSTRAINT `inventory_ibfk_2` FOREIGN KEY (`fulfillment_center_id`) REFERENCES `fulfillment_centers` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
-- Create "orders" table
CREATE TABLE `orders` (
                          `id` int NOT NULL,
                          `user_id` int NOT NULL,
                          `fulfillment_center_id` int NOT NULL,
                          `total_amount` decimal(10,2) NOT NULL,
                          `comment` varchar(100) NULL,
                          `status` varchar(50) NOT NULL DEFAULT 'PENDING',
                          `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                          `updated_at` timestamp NULL ON UPDATE CURRENT_TIMESTAMP,
                          PRIMARY KEY (`id`),
                          INDEX `fulfillment_center_id` (`fulfillment_center_id`),
                          INDEX `user_id` (`user_id`),
                          CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE,
                          CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`fulfillment_center_id`) REFERENCES `fulfillment_centers` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
-- Create "order_items" table
CREATE TABLE `order_items` (
                               `id` int NOT NULL,
                               `order_id` int NOT NULL,
                               `product_id` int NOT NULL,
                               `quantity` int NOT NULL,
                               `price` decimal(10,2) NOT NULL,
                               PRIMARY KEY (`id`),
                               INDEX `order_id` (`order_id`),
                               INDEX `product_id` (`product_id`),
                               CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE,
                               CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
-- Create "posts" table
CREATE TABLE `posts` (
                         `id` int NOT NULL,
                         `user_id` int NOT NULL,
                         `title` varchar(255) NOT NULL,
                         `body` text NOT NULL,
                         PRIMARY KEY (`id`),
                         INDEX `user_id` (`user_id`),
                         CONSTRAINT `posts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;