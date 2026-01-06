-- Modify "payment_methods" table
ALTER TABLE `payment_methods` ADD CONSTRAINT `payment_methods_chk_1` CHECK (regexp_like(`card_number`,_utf8mb4'^[0-9]{12,20}$'));
