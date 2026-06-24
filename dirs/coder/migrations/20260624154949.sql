-- Modify "workspaces" table
ALTER TABLE "workspaces" ADD CONSTRAINT "workspaces_last_used_at_not_negative_epoch" CHECK (last_used_at >= '1970-01-01 00:00:00'::timestamp without time zone);
