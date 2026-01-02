-- Modify "users" table
ALTER TABLE "users" ADD CONSTRAINT "users_username_no_surrounding_whitespace" CHECK (username = btrim(username));
