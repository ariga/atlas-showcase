-- Insert into "fulfillment_centers" table
INSERT INTO `fulfillment_centers` (`id`, `name`, `location`) VALUES
(1, 'Tel Aviv Center', 'Tel Aviv'),
(2, 'Jerusalem Center', 'Jerusalem'),
(3, 'Haifa Center', 'Haifa');

-- Insert into "inventory" table
-- Let's assume that each fulfillment center has 50 of each product in inventory
INSERT INTO `inventory` (`id`, `product_id`, `fulfillment_center_id`, `quantity`) VALUES
(1, 1, 1, 50),
(2, 2, 1, 50),
(3, 3, 1, 50),
(4, 4, 1, 50),
(5, 5, 1, 50),
(6, 1, 2, 50),
(7, 2, 2, 50),
(8, 3, 2, 50),
(9, 4, 2, 50),
(10, 5, 2, 50),
(11, 1, 3, 50),
(12, 2, 3, 50),
(13, 3, 3, 50),
(14, 4, 3, 50),
(15, 5, 3, 50);

