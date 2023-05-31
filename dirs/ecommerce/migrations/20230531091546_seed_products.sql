-- Insert into "categories" table
INSERT INTO `categories` (`id`, `category_name`) VALUES
(1, 'Fruits'),
(2, 'Vegetables'),
(3, 'Dairy'),
(4, 'Bakery');

-- Insert into "products" table
INSERT INTO `products` (`id`, `product_name`, `description`, `price`, `category_id`) VALUES
(1, 'Apple', 'Fresh apples', 0.99, 1),
(2, 'Banana', 'Ripe bananas', 0.79, 1),
(3, 'Orange', 'Juicy oranges', 1.09, 1),
(4, 'Pineapple', 'Sweet pineapple', 2.99, 1),
(5, 'Mango', 'Delicious mangoes', 1.49, 1),
(6, 'Carrot', 'Crunchy carrots', 0.89, 2),
(7, 'Potato', 'Starchy potatoes', 0.59, 2),
(8, 'Tomato', 'Ripe tomatoes', 1.19, 2),
(9, 'Cucumber', 'Fresh cucumbers', 0.99, 2),
(10, 'Broccoli', 'Healthy broccoli', 1.49, 2),
(11, 'Milk', 'Fresh milk', 2.49, 3),
(12, 'Cheese', 'Cheddar cheese', 3.99, 3),
(13, 'Butter', 'Creamy butter', 2.99, 3),
(14, 'Yogurt', 'Greek yogurt', 1.99, 3),
(15, 'Cream', 'Heavy cream', 2.39, 3),
(16, 'Bread', 'Whole grain bread', 2.99, 4),
(17, 'Bagel', 'Fresh bagels', 0.99, 4),
(18, 'Croissant', 'Buttery croissants', 1.99, 4),
(19, 'Muffin', 'Blueberry muffins', 1.49, 4),
(20, 'Donut', 'Glazed donuts', 0.99, 4);

