-- Modify "orders" table
ALTER TABLE `orders` ADD COLUMN `modified_by` int NULL COMMENT "User ID of the person who last modified the order", ADD INDEX `orders_ibfk_3` (`modified_by`), ADD CONSTRAINT `orders_ibfk_3` FOREIGN KEY (`modified_by`) REFERENCES `users` (`id`) ON UPDATE NO ACTION ON DELETE SET NULL;
