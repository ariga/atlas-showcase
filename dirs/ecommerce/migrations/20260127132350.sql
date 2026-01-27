-- Modify "users" table
ALTER TABLE `users` ADD INDEX `users_email_address_lower` ((lower(`email_address`)));
