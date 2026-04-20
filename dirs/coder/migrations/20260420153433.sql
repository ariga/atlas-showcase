-- Modify "users" table
ALTER TABLE "users" ADD CONSTRAINT "users_updated_at_not_before_created_at" CHECK (updated_at >= created_at);
