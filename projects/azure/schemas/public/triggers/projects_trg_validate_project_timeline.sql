-- atlas:import ../functions/validate_project_timeline.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/projects.sql

-- create trigger "trg_validate_project_timeline"
CREATE TRIGGER "trg_validate_project_timeline" BEFORE INSERT OR UPDATE ON "public"."projects" FOR EACH ROW EXECUTE FUNCTION "public"."validate_project_timeline"();
