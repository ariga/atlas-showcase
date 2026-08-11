-- Modify "users" table
ALTER TABLE `users` DROP INDEX `phone_number`;
-- Modify "users" table
ALTER TABLE `users` ADD UNIQUE INDEX `phone_number` ((coalesce(`phone_number`,concat(_utf8mb4'NULL#',`id`))));
