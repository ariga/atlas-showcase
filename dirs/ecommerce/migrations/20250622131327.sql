-- Modify "products" table
ALTER TABLE `products` MODIFY COLUMN `status` enum('active','inactive','discontinued') NOT NULL DEFAULT "active" COMMENT "Status of the product";
