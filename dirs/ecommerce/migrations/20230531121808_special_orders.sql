CREATE TABLE `special_orders` (
  `id` int NOT NULL,
  `order_id` int NOT NULL REFERENCES `orders`(`id`),
  PRIMARY KEY(`id`)
);
