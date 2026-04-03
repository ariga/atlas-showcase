-- Modify "workspaces" table
ALTER TABLE "workspaces" DROP CONSTRAINT "workspaces_last_used_at_not_before_sentinel", ADD CONSTRAINT "workspaces_last_used_at_not_before_sentinel" CHECK (last_activity_at >= '0001-01-01 00:00:00'::timestamp without time zone), DROP COLUMN "last_used_at", ADD COLUMN "last_activity_at" timestamp NOT NULL DEFAULT '0001-01-01 00:00:00';
