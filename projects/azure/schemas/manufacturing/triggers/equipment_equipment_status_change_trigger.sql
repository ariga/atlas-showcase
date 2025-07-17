-- atlas:import ../functions/equipment_status_change_notification.sql
-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/equipment.sql

-- create trigger "equipment_status_change_trigger"
CREATE TRIGGER "equipment_status_change_trigger" AFTER UPDATE ON "manufacturing"."equipment" FOR EACH ROW WHEN (old.status IS DISTINCT FROM new.status) EXECUTE FUNCTION "manufacturing"."equipment_status_change_notification"();
