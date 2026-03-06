-- Create index "workspaces_org_active_idx" to table: "workspaces"
CREATE INDEX "workspaces_org_active_idx" ON "workspaces" ("organization_id") WHERE (deleted = false);
