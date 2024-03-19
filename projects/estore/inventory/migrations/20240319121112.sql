-- atlas:txtar

-- checks/destructive.sql --
-- atlas:assert DS103
SELECT NOT EXISTS (SELECT 1 FROM `products` WHERE `price` IS NOT NULL) AS `is_empty`;

-- migration.sql --
-- Modify "products" table
ALTER TABLE `products` DROP COLUMN `price`;
