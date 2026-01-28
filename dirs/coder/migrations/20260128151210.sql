-- Modify "users" table
ALTER TABLE "users" ADD CONSTRAINT "users_username_lowercase_only" CHECK (username = lower(username));
