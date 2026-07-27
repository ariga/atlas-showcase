-- Modify "users" table
ALTER TABLE "users" ADD CONSTRAINT "users_username_normalized" CHECK ((username = lower(btrim(username))) AND (length(btrim(username)) > 0));
