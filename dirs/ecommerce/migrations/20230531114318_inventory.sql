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
