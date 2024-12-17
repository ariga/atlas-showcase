-- Create 'users' table
CREATE TABLE `users` (
    `id` int NOT NULL COMMENT 'Unique identifier for each user',
    `user_name` varchar(255) NOT NULL COMMENT 'The username of the user, must be unique',
    `email` varchar(255) NOT NULL,
    `phone_number` varchar(15) NOT NULL,
    `country_code` varchar(5) NOT NULL DEFAULT '+1' COMMENT 'Country code for the phone number, defaults to US',
    `is_admin` bool NULL DEFAULT 0 COMMENT 'Flag indicating if the user is an admin, defaults to false',
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of when the user was created',
    `updated_at` timestamp NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp of the last update to the user record',
    `date_of_birth` date NULL,
    `gender` ENUM('male', 'female', 'other') NULL COMMENT 'User gender',
    `middle_name` varchar(255) NULL COMMENT 'Middle name of the user, optional',
    `active` bool NOT NULL DEFAULT 1 COMMENT 'Flag indicating if the user account is active, defaults to true',
    `last_login` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of the last login of the user',
    `address` varchar(255) NULL,
    `profile_picture_url` varchar(255) NULL COMMENT 'URL to the user profile picture',
    `phone_verified` bool NOT NULL DEFAULT 0 COMMENT 'Flag indicating if the user phone number is verified, defaults to false',
    `deleted_at` timestamp NULL COMMENT 'Timestamp for soft deletion of the user record',
    PRIMARY KEY (`id`),
    UNIQUE INDEX `email` (`email`),
    UNIQUE INDEX `user_name` (`user_name`),
    UNIQUE INDEX `phone_number` (`phone_number`),
    UNIQUE INDEX `user_name_email` (`user_name`, `email`),
    CHECK (`email` REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
    CHECK (`phone_number` REGEXP '^[0-9]{1,15}$')
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT 'Table storing user information, including authentication and profile details';

-- Create 'categories' table
CREATE TABLE `categories` (
    `id` int NOT NULL COMMENT 'Unique identifier for each category',
    `category_name` varchar(255) NOT NULL COMMENT 'The name of the category, must be unique',
    `category_description` text NULL COMMENT 'Description of the category',
    `category_code` varchar(100) NOT NULL UNIQUE COMMENT 'Unique code for the category',
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of when the category was created',
    `updated_at` timestamp NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp of the last update to the category record',
    PRIMARY KEY (`id`)
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT 'Table for storing product categories, facilitating product classification';

-- Create 'products' table
CREATE TABLE `products` (
    `id` int NOT NULL COMMENT 'Unique identifier for each product',
    `product_name` varchar(255) NOT NULL COMMENT 'Name of the product',
    `price` decimal(10,2) NOT NULL COMMENT 'Price of the product',
    `currency_code` varchar(3) NOT NULL DEFAULT 'USD' COMMENT 'Currency code for the product price',
    `category_id` int NULL COMMENT 'Foreign key referencing categories',
    `description` text NULL COMMENT 'Description of the product',
    `image_url` varchar(255) NULL COMMENT 'URL to the product image',
    `thumbnail_url` varchar(255) NULL COMMENT 'URL to the product thumbnail image',
    `featured` bool NOT NULL DEFAULT 0 COMMENT 'Flag indicating if the product is featured, defaults to false',
    `status` varchar(50) NOT NULL DEFAULT 'active' COMMENT 'Current status of the product (e.g., active, inactive)',
    `discount` decimal(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Discount amount on the product',
    PRIMARY KEY (`id`),
    INDEX `category_id` (`category_id`),
    UNIQUE INDEX `product_name` (`product_name`),
    CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON UPDATE NO ACTION ON DELETE SET NULL,
    CHECK (`discount` BETWEEN 0.00 AND 100.00)
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT 'Table for storing product details, including pricing and category associations';

-- Create 'product_reviews' table
CREATE TABLE `product_reviews` (
    `id` int NOT NULL COMMENT 'Unique identifier for each review',
    `product_id` int NOT NULL COMMENT 'Foreign key referencing the product being reviewed',
    `user_id` int NOT NULL COMMENT 'Foreign key referencing the user who made the review',
    `rating` int NOT NULL COMMENT 'Rating given by the user (1 to 5)',
    `review_text` text NOT NULL COMMENT 'Review text provided by the user',
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of when the review was created',
    PRIMARY KEY (`id`),
    INDEX `product_id` (`product_id`),
    INDEX `user_id` (`user_id`),
    UNIQUE INDEX `user_product_review` (`user_id`, `product_id`),
    CONSTRAINT `product_reviews_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE,
    CONSTRAINT `product_reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT 'Table for storing reviews of products by users';

-- Create 'fulfillment_centers' table
CREATE TABLE `fulfillment_centers` (
    `id` int NOT NULL COMMENT 'Unique identifier for each fulfillment center',
    `name` varchar(255) NOT NULL COMMENT 'Name of the fulfillment center',
    `location` varchar(255) NOT NULL COMMENT 'Physical location of the fulfillment center',
    PRIMARY KEY (`id`)
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT 'Table for storing fulfillment center details for product shipping';

-- Create 'inventory' table
CREATE TABLE `inventory` (
    `id` int NOT NULL COMMENT 'Unique identifier for each inventory record',
    `product_id` int NOT NULL COMMENT 'Foreign key referencing the product',
    `fulfillment_center_id` int NOT NULL COMMENT 'Foreign key referencing the fulfillment center',
    `quantity` int NOT NULL DEFAULT 0 COMMENT 'Available quantity of the product in the fulfillment center',
    PRIMARY KEY (`id`),
    INDEX `fulfillment_center_id` (`fulfillment_center_id`),
    INDEX `product_id` (`product_id`),
    CONSTRAINT `inventory_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE,
    CONSTRAINT `inventory_ibfk_2` FOREIGN KEY (`fulfillment_center_id`) REFERENCES `fulfillment_centers` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE,
    CHECK (`quantity` >= 0)
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT 'Table for managing inventory levels of products at various fulfillment centers';

-- Create 'orders' table
CREATE TABLE `orders` (
    `id` int NOT NULL COMMENT 'Unique identifier for each order',
    `user_id` int NOT NULL COMMENT 'Foreign key referencing the user who placed the order',
    `fulfillment_center_id` int NOT NULL COMMENT 'Foreign key referencing the fulfillment center for the order',
    `total_amount` decimal(10,2) NOT NULL COMMENT 'Total amount for the order',
    `comment` varchar(100) NULL COMMENT 'Optional comment for the order',
    `status` varchar(50) NOT NULL DEFAULT 'PENDING' COMMENT 'Current status of the order',
    `shipping_address` varchar(255) NOT NULL COMMENT 'Shipping address for the order',
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of when the order was created',
    `updated_at` timestamp NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'Timestamp of the last update to the order record',
    `order_reference` varchar(100) NULL COMMENT 'Optional reference number for the order',
    `is_featured` bool NOT NULL DEFAULT 0 COMMENT 'Flag indicating if the order is featured, defaults to false',
    PRIMARY KEY (`id`),
    INDEX `fulfillment_center_id` (`fulfillment_center_id`),
    INDEX `user_id` (`user_id`),
    CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE,
    CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`fulfillment_center_id`) REFERENCES `fulfillment_centers` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE,
    CHECK (`total_amount` >= 0)
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT 'Table for storing orders placed by users';

-- Create 'order_items' table
CREATE TABLE `order_items` (
    `id` int NOT NULL COMMENT 'Unique identifier for each order item',
    `order_id` int NOT NULL COMMENT 'Foreign key referencing the order',
    `product_id` int NOT NULL COMMENT 'Foreign key referencing the product',
    `quantity` int NOT NULL COMMENT 'Quantity of the product in the order',
    `price` decimal(10,2) NOT NULL COMMENT 'Price of the product at the time of order',
    `order_reference` varchar(100) NULL COMMENT 'Optional reference number for the order',
    PRIMARY KEY (`id`),
    INDEX `order_id` (`order_id`),
    INDEX `product_id` (`product_id`),
    CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE,
    CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT 'Table for storing items in each order placed by users';

-- Create 'posts' table
CREATE TABLE `posts` (
    `id` int NOT NULL,
    `user_id` int NOT NULL,
    `title` varchar(255) NOT NULL,
    `body` text NOT NULL,
    `last_updated_by` int NULL,
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp of when the post was created',
    PRIMARY KEY (`id`),
    INDEX `user_id` (`user_id`),
    CONSTRAINT `posts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE,
    CONSTRAINT `posts_ibfk_2` FOREIGN KEY (`last_updated_by`) REFERENCES `users` (`id`) ON UPDATE NO ACTION ON DELETE SET NULL
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

-- Create 'payment_methods' table
CREATE TABLE `payment_methods` (
    `id` int NOT NULL,
    `user_id` int NOT NULL,
    `card_number` varchar(20) NOT NULL,
    `expiration_date` date NOT NULL,
    `cardholder_name` varchar(255) NOT NULL,
    `status` varchar(50) NOT NULL DEFAULT 'active',
    `updated_at` timestamp NULL ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `user_id` (`user_id`),
    CONSTRAINT `payment_methods_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
