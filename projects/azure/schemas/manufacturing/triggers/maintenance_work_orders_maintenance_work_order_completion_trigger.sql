-- atlas:import ../functions/maintenance_work_order_completion.sql
-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/maintenance_work_orders.sql

-- create trigger "maintenance_work_order_completion_trigger"
CREATE TRIGGER "maintenance_work_order_completion_trigger" BEFORE UPDATE ON "manufacturing"."maintenance_work_orders" FOR EACH ROW EXECUTE FUNCTION "manufacturing"."maintenance_work_order_completion"();
