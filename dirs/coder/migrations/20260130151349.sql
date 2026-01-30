-- Modify "users" table
ALTER TABLE "users" ADD CONSTRAINT "users_email_lowercase_only" CHECK (email = lower(email));
