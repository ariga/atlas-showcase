-- Modify "payment_methods" table
ALTER TABLE `payment_methods` ADD CONSTRAINT `payment_methods_chk_2` CHECK (`status` = lower(`status`));
