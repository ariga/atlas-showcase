-- Modify "payment_methods" table
ALTER TABLE `payment_methods` ADD UNIQUE INDEX `user_card_number` (`user_id`, `card_number`);
