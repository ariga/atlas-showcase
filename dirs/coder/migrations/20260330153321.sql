-- Modify "users" table
ALTER TABLE "users" ADD CONSTRAINT "users_email_normalized" CHECK ((email = lower(btrim(email))) AND (length(btrim(email)) > 0));
