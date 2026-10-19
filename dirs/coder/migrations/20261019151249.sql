-- Modify "users" table
ALTER TABLE "users" ADD CONSTRAINT "users_updated_at_not_before_sentinel" CHECK (updated_at >= '0001-01-01 00:00:00+00'::timestamp with time zone);
