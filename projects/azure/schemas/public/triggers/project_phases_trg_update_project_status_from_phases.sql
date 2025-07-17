-- atlas:import ../functions/update_project_status_from_phases.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/project_phases.sql

-- create trigger "trg_update_project_status_from_phases"
CREATE TRIGGER "trg_update_project_status_from_phases" AFTER UPDATE OF "status" ON "public"."project_phases" FOR EACH ROW EXECUTE FUNCTION "public"."update_project_status_from_phases"();
