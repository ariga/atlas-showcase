-- atlas:import ../functions/supplier_rating_change_notification.sql
-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/suppliers.sql

-- create trigger "supplier_rating_update_trigger"
CREATE TRIGGER "supplier_rating_update_trigger" AFTER UPDATE ON "manufacturing"."suppliers" FOR EACH ROW WHEN ((old.quality_rating IS DISTINCT FROM new.quality_rating) OR (old.delivery_rating IS DISTINCT FROM new.delivery_rating) OR (old.cost_rating IS DISTINCT FROM new.cost_rating)) EXECUTE FUNCTION "manufacturing"."supplier_rating_change_notification"();
