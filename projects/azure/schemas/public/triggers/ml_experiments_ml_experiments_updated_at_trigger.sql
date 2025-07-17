-- atlas:import ../functions/update_updated_at.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/ml_experiments.sql

-- create trigger "ml_experiments_updated_at_trigger"
CREATE TRIGGER "ml_experiments_updated_at_trigger" BEFORE UPDATE ON "public"."ml_experiments" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();
