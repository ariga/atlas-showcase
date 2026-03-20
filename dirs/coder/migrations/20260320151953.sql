-- Modify "users" table
ALTER TABLE "users" ADD CONSTRAINT "users_hashed_password_not_empty" CHECK (octet_length(hashed_password) > 0);
