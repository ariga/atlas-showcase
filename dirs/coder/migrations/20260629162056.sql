-- Create index "workspace_builds_deadline_idx" to table: "workspace_builds"
CREATE INDEX "workspace_builds_deadline_idx" ON "workspace_builds" ("deadline") WHERE (deadline > '0001-01-01 00:00:00+00'::timestamp with time zone);
