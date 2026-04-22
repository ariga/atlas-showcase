-- Modify "users" table
ALTER TABLE "users" ADD CONSTRAINT "users_last_seen_at_not_null" CHECK (last_seen_at IS NOT NULL);
