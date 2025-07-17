-- atlas:import ../functions/update_device_last_seen.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/iot_sensor_data.sql

-- create trigger "trg_update_device_last_seen"
CREATE TRIGGER "trg_update_device_last_seen" AFTER INSERT ON "public"."iot_sensor_data" FOR EACH ROW EXECUTE FUNCTION "public"."update_device_last_seen"();
