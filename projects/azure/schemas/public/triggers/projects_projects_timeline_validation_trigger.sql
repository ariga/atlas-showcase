-- atlas:import ../functions/validate_project_timeline.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/projects.sql

-- create trigger "projects_timeline_validation_trigger"
CREATE TRIGGER "projects_timeline_validation_trigger" BEFORE INSERT OR UPDATE ON "public"."projects" FOR EACH ROW EXECUTE FUNCTION "public"."validate_project_timeline"();
