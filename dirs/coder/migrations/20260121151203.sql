-- Modify "users" table
ALTER TABLE "users" ADD CONSTRAINT "users_last_seen_at_not_before_sentinel" CHECK (last_seen_at >= '0001-01-01 00:00:00'::timestamp without time zone);
