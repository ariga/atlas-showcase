-- Create "payment_methods" table
CREATE TABLE `payment_methods` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `card_number` varchar(20) NOT NULL,
  `expiration_date` date NOT NULL,
  `cardholder_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `user_id` (`user_id`),
  CONSTRAINT `payment_methods_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE
) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
