-- Modify "users" table
ALTER TABLE `users` ADD COLUMN `last_order_date` date NULL COMMENT "Date of the user's last order";
