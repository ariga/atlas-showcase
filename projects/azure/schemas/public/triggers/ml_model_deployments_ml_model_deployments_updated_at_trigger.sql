-- atlas:import ../functions/update_updated_at.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/ml_model_deployments.sql

-- create trigger "ml_model_deployments_updated_at_trigger"
CREATE TRIGGER "ml_model_deployments_updated_at_trigger" BEFORE UPDATE ON "public"."ml_model_deployments" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();
