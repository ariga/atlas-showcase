-- atlas:import ../functions/update_project_status_from_phases.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/project_phases.sql

-- create trigger "project_status_from_phases_trigger"
CREATE TRIGGER "project_status_from_phases_trigger" AFTER DELETE OR INSERT OR UPDATE ON "public"."project_phases" FOR EACH ROW EXECUTE FUNCTION "public"."update_project_status_from_phases"();
