-- atlas:import ../functions/update_updated_at.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/project_milestones.sql

-- create trigger "project_milestones_updated_at_trigger"
CREATE TRIGGER "project_milestones_updated_at_trigger" BEFORE UPDATE ON "public"."project_milestones" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();
