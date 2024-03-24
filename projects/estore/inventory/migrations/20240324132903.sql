-- Modify "products" table
ALTER TABLE `products` ADD COLUMN `price` decimal(10,2) NOT NULL;
-- Create "price_avgs" view
CREATE VIEW `price_avgs` (
  `category_name`,
  `avg_price`
) AS select `categories`.`name` AS `category_name`,avg(`products`.`price`) AS `avg_price` from (`categories` join `products` on((`categories`.`category_id` = `products`.`category_id`))) group by `categories`.`name`;
