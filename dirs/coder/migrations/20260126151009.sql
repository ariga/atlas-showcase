-- Modify "users" table
ALTER TABLE "users" ADD CONSTRAINT "users_last_seen_at_not_in_future" CHECK (last_seen_at <= (now() AT TIME ZONE 'UTC'::text));
