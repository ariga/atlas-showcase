-- Create index "workspace_agent_metadata_agent_collected_at_desc_idx" to table: "workspace_agent_metadata"
CREATE INDEX "workspace_agent_metadata_agent_collected_at_desc_idx" ON "workspace_agent_metadata" ("workspace_agent_id", "collected_at" DESC);
