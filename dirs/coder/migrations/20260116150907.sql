-- Modify "users" table
ALTER TABLE "users" ADD CONSTRAINT "users_email_not_empty" CHECK (length(btrim(email)) > 0);
