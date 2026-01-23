-- Modify "users" table
ALTER TABLE "users" ADD CONSTRAINT "users_username_not_empty" CHECK (length(btrim(username)) > 0);
