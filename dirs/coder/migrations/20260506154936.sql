-- Modify "workspace_agent_metadata" table
ALTER TABLE "workspace_agent_metadata" ADD CONSTRAINT "workspace_agent_metadata_collected_at_not_before_sentinel" CHECK (collected_at >= '0001-01-01 00:00:00+00'::timestamp with time zone);
