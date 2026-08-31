-- Create index "workspaces_organization_deleted_idx" to table: "workspaces"
CREATE INDEX "workspaces_organization_deleted_idx" ON "workspaces" ("organization_id", "deleted");
