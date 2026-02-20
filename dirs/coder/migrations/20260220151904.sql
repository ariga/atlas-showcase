-- Modify "workspaces" table
ALTER TABLE "workspaces" ADD CONSTRAINT "workspaces_last_used_at_not_before_sentinel" CHECK (last_used_at >= '0001-01-01 00:00:00'::timestamp without time zone);
