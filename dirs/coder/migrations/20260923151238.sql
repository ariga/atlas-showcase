-- Set comment to column: "default_value" on table: "template_version_variables"
COMMENT ON COLUMN "template_version_variables"."default_value" IS 'Variable type';
-- Modify "users" table
ALTER TABLE "users" ADD CONSTRAINT "users_email_max_len_320" CHECK (length(email) <= 320);
