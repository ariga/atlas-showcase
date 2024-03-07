-- Create "inventory_by_region" table
CREATE TABLE `inventory_by_region` (
  `region_id` int NOT NULL,
  `product_id` int NOT NULL,
  `total_quantity` int NULL,
  PRIMARY KEY (`region_id`, `product_id`),
  INDEX `product_id` (`product_id`),
  CONSTRAINT `inventory_by_region_ibfk_1` FOREIGN KEY (`region_id`) REFERENCES `regions` (`region_id`) ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT `inventory_by_region_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON UPDATE NO ACTION ON DELETE NO ACTION
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
