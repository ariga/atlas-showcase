-- atlas:import ../functions/update_updated_at.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/project_phases.sql

-- create trigger "project_phases_updated_at_trigger"
CREATE TRIGGER "project_phases_updated_at_trigger" BEFORE UPDATE ON "public"."project_phases" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();
