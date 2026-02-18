-- Create index "workspace_builds_workspace_id_created_at_desc_idx" to table: "workspace_builds"
CREATE INDEX "workspace_builds_workspace_id_created_at_desc_idx" ON "workspace_builds" ("workspace_id", "created_at" DESC);
