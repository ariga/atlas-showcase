-- Modify "users" table
ALTER TABLE "users" ADD CONSTRAINT "users_email_no_surrounding_whitespace" CHECK (email = btrim(email));
