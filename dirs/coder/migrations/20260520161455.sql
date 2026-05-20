-- Modify "workspaces" table
ALTER TABLE "workspaces" ADD CONSTRAINT "workspaces_last_used_at_not_in_future" CHECK (last_used_at <= (now() AT TIME ZONE 'UTC'::text));
