-- atlas:import ../functions/update_updated_at.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/ml_datasets.sql

-- create trigger "ml_datasets_updated_at_trigger"
CREATE TRIGGER "ml_datasets_updated_at_trigger" BEFORE UPDATE ON "public"."ml_datasets" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at"();
