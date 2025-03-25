-- Modify "users" table
ALTER TABLE `users` ADD COLUMN `roles` enum('admin','customer','seller') NOT NULL DEFAULT "customer" COMMENT "Role of the user in the system";
