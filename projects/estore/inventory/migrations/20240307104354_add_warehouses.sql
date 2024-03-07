-- Create "regions" table
CREATE TABLE `regions` (
  `region_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`region_id`)
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
-- Create "warehouses" table
CREATE TABLE `warehouses` (
  `warehouse_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `address` text NOT NULL,
  `region_id` int NULL,
  PRIMARY KEY (`warehouse_id`),
  INDEX `region_id` (`region_id`),
  CONSTRAINT `warehouses_ibfk_1` FOREIGN KEY (`region_id`) REFERENCES `regions` (`region_id`) ON UPDATE NO ACTION ON DELETE NO ACTION
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
