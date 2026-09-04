-- Modify "workspace_builds" table
ALTER TABLE "workspace_builds" ADD CONSTRAINT "workspace_builds_build_number_non_negative" CHECK (build_number >= 0);
