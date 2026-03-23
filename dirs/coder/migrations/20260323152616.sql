-- Modify "users" table
ALTER TABLE "users" DROP CONSTRAINT "users_last_seen_at_not_before_sentinel", ADD CONSTRAINT "users_last_seen_at_not_before_sentinel" CHECK (last_seen_at >= '0001-01-01 00:00:00+00'::timestamp with time zone), ALTER COLUMN "last_seen_at" TYPE timestamptz, ALTER COLUMN "last_seen_at" SET DEFAULT '0001-01-01 00:00:00+00';
