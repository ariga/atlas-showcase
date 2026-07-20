-- Create index "workspaces_owner_last_used_at_desc_idx" to table: "workspaces"
CREATE INDEX "workspaces_owner_last_used_at_desc_idx" ON "workspaces" ("owner_id", "last_used_at" DESC) WHERE (deleted = false);
