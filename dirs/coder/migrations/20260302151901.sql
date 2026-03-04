-- Drop index "idx_users_email" from table: "users"
DROP INDEX "idx_users_email";
-- Modify "users" table
ALTER TABLE "users" DROP CONSTRAINT "users_email_lowercase_only", ADD CONSTRAINT "users_email_lowercase_only" CHECK (email_address = lower(email_address)), DROP CONSTRAINT "users_email_no_surrounding_whitespace", ADD CONSTRAINT "users_email_no_surrounding_whitespace" CHECK (email_address = btrim(email_address)), DROP CONSTRAINT "users_email_not_empty", ADD CONSTRAINT "users_email_not_empty" CHECK (length(btrim(email_address)) > 0), DROP COLUMN "email", ADD COLUMN "email_address" text NOT NULL;
-- Create index "idx_users_email" to table: "users"
CREATE UNIQUE INDEX "idx_users_email" ON "users" ("email_address") WHERE (deleted = false);
