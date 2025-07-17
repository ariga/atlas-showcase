-- atlas:import ../functions/production_run_quality_check.sql
-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/production_runs.sql

-- create trigger "production_run_quality_trigger"
CREATE TRIGGER "production_run_quality_trigger" BEFORE UPDATE ON "manufacturing"."production_runs" FOR EACH ROW EXECUTE FUNCTION "manufacturing"."production_run_quality_check"();
