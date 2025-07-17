-- atlas:import ../functions/update_updated_at.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/projects.sql

-- create trigger "projects_updated_at_trigger"
CREATE TRIGGER "projects_updated_at_trigger" BEFORE UPDATE ON "public"."projects" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();
