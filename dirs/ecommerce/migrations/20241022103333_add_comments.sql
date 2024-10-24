-- Modify "categories" table
ALTER TABLE `categories` COMMENT "Table for storing product categories, facilitating product classification", MODIFY COLUMN `id` int NOT NULL COMMENT "Unique identifier for each category", MODIFY COLUMN `category_name` varchar(255) NOT NULL COMMENT "The name of the category, must be unique", MODIFY COLUMN `category_description` text NULL COMMENT "Description of the category", MODIFY COLUMN `category_code` varchar(100) NOT NULL COMMENT "Unique code for the category", MODIFY COLUMN `updated_at` timestamp NULL ON UPDATE CURRENT_TIMESTAMP COMMENT "Timestamp of the last update to the category record", MODIFY COLUMN `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT "Timestamp of when the category was created";
-- Modify "fulfillment_centers" table
ALTER TABLE `fulfillment_centers` COMMENT "Table for storing fulfillment center details for product shipping", MODIFY COLUMN `id` int NOT NULL COMMENT "Unique identifier for each fulfillment center", MODIFY COLUMN `name` varchar(255) NOT NULL COMMENT "Name of the fulfillment center", MODIFY COLUMN `location` varchar(255) NOT NULL COMMENT "Physical location of the fulfillment center";
-- Modify "inventory" table
ALTER TABLE `inventory` COMMENT "Table for managing inventory levels of products at various fulfillment centers", MODIFY COLUMN `id` int NOT NULL COMMENT "Unique identifier for each inventory record", MODIFY COLUMN `product_id` int NOT NULL COMMENT "Foreign key referencing the product", MODIFY COLUMN `fulfillment_center_id` int NOT NULL COMMENT "Foreign key referencing the fulfillment center", MODIFY COLUMN `quantity` int NOT NULL COMMENT "Available quantity of the product in the fulfillment center";
-- Modify "order_items" table
ALTER TABLE `order_items` COMMENT "Table for storing items in each order placed by users", MODIFY COLUMN `id` int NOT NULL COMMENT "Unique identifier for each order item", MODIFY COLUMN `order_id` int NOT NULL COMMENT "Foreign key referencing the order", MODIFY COLUMN `product_id` int NOT NULL COMMENT "Foreign key referencing the product", MODIFY COLUMN `quantity` int NOT NULL COMMENT "Quantity of the product in the order", MODIFY COLUMN `price` decimal(10,2) NOT NULL COMMENT "Price of the product at the time of order", MODIFY COLUMN `order_reference` varchar(100) NULL COMMENT "Optional reference number for the order";
-- Modify "orders" table
ALTER TABLE `orders` COMMENT "Table for storing orders placed by users", MODIFY COLUMN `id` int NOT NULL COMMENT "Unique identifier for each order", MODIFY COLUMN `user_id` int NOT NULL COMMENT "Foreign key referencing the user who placed the order", MODIFY COLUMN `fulfillment_center_id` int NOT NULL COMMENT "Foreign key referencing the fulfillment center for the order", MODIFY COLUMN `total_amount` decimal(10,2) NOT NULL COMMENT "Total amount for the order", MODIFY COLUMN `comment` varchar(100) NULL COMMENT "Optional comment for the order", MODIFY COLUMN `status` varchar(50) NOT NULL DEFAULT "PENDING" COMMENT "Current status of the order", MODIFY COLUMN `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT "Timestamp of when the order was created", MODIFY COLUMN `updated_at` timestamp NULL ON UPDATE CURRENT_TIMESTAMP COMMENT "Timestamp of the last update to the order record", MODIFY COLUMN `shipping_address` varchar(255) NOT NULL COMMENT "Shipping address for the order", MODIFY COLUMN `order_reference` varchar(100) NULL COMMENT "Optional reference number for the order";
-- Modify "product_reviews" table
ALTER TABLE `product_reviews` COMMENT "Table for storing reviews of products by users", DROP CONSTRAINT `product_reviews_chk_1`, MODIFY COLUMN `id` int NOT NULL COMMENT "Unique identifier for each review", MODIFY COLUMN `product_id` int NOT NULL COMMENT "Foreign key referencing the product being reviewed", MODIFY COLUMN `user_id` int NOT NULL COMMENT "Foreign key referencing the user who made the review", MODIFY COLUMN `rating` int NOT NULL COMMENT "Rating given by the user (1 to 5)", MODIFY COLUMN `review_text` text NOT NULL COMMENT "Review text provided by the user", MODIFY COLUMN `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT "Timestamp of when the review was created";
-- Modify "products" table
ALTER TABLE `products` COMMENT "Table for storing product details, including pricing and category associations", MODIFY COLUMN `id` int NOT NULL COMMENT "Unique identifier for each product", MODIFY COLUMN `product_name` varchar(255) NOT NULL COMMENT "Name of the product", MODIFY COLUMN `price` decimal(10,2) NOT NULL COMMENT "Price of the product", MODIFY COLUMN `category_id` int NULL COMMENT "Foreign key referencing categories", MODIFY COLUMN `description` text NULL COMMENT "Description of the product", MODIFY COLUMN `featured` bool NOT NULL DEFAULT 0 COMMENT "Flag indicating if the product is featured, defaults to false", MODIFY COLUMN `status` varchar(50) NOT NULL DEFAULT "active" COMMENT "Current status of the product (e.g., active, inactive)", MODIFY COLUMN `image_url` varchar(255) NULL COMMENT "URL to the product image", MODIFY COLUMN `discount` decimal(5,2) NOT NULL DEFAULT 0.00 COMMENT "Discount amount on the product";
-- Modify "users" table
ALTER TABLE `users` COMMENT "Table storing user information, including authentication and profile details", MODIFY COLUMN `id` int NOT NULL COMMENT "Unique identifier for each user", MODIFY COLUMN `user_name` varchar(255) NOT NULL COMMENT "The username of the user, must be unique", MODIFY COLUMN `is_admin` bool NULL DEFAULT 0 COMMENT "Flag indicating if the user is an admin, defaults to false", MODIFY COLUMN `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT "Timestamp of when the user was created", MODIFY COLUMN `updated_at` timestamp NULL ON UPDATE CURRENT_TIMESTAMP COMMENT "Timestamp of the last update to the user record", MODIFY COLUMN `active` bool NOT NULL DEFAULT 1 COMMENT "Flag indicating if the user account is active, defaults to true", MODIFY COLUMN `profile_picture_url` varchar(255) NULL COMMENT "URL to the user profile picture", MODIFY COLUMN `phone_verified` bool NOT NULL DEFAULT 0 COMMENT "Flag indicating if the user phone number is verified, defaults to false", MODIFY COLUMN `deleted_at` timestamp NULL COMMENT "Timestamp for soft deletion of the user record", MODIFY COLUMN `country_code` varchar(5) NOT NULL DEFAULT "+1" COMMENT "Country code for the phone number, defaults to US";
