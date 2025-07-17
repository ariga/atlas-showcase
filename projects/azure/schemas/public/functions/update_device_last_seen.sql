-- atlas:import ../public.sql
-- atlas:import ../tables/iot_devices.sql

-- create "update_device_last_seen" function
CREATE FUNCTION "public"."update_device_last_seen" () RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    UPDATE iot_devices 
    SET last_seen = NEW.timestamp 
    WHERE id = NEW.device_id;
    RETURN NEW;
END;
$$;
