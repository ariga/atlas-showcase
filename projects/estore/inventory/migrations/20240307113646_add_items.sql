-- Create "inventory_items" table
CREATE TABLE `inventory_items` (
  `inventory_id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NULL,
  `warehouse_id` int NULL,
  `quantity` int NULL DEFAULT 0,
  PRIMARY KEY (`inventory_id`),
  INDEX `product_id` (`product_id`),
  INDEX `warehouse_id` (`warehouse_id`),
  CONSTRAINT `inventory_items_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT `inventory_items_ibfk_2` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`warehouse_id`) ON UPDATE NO ACTION ON DELETE NO ACTION
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
