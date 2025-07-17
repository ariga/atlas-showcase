-- atlas:import check_sensor_anomaly.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/iot_sensor_data.sql
-- atlas:import ../types/enum_sensor_type.sql

-- create "get_device_telemetry_summary" function
CREATE FUNCTION "public"."get_device_telemetry_summary" ("p_device_id" integer, "p_start_time" timestamptz, "p_end_time" timestamptz) RETURNS TABLE ("sensor_type" "public"."sensor_type", "avg_value" numeric, "min_value" numeric, "max_value" numeric, "reading_count" bigint, "anomaly_count" bigint) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        sd.sensor_type,
        AVG(sd.value) as avg_value,
        MIN(sd.value) as min_value,
        MAX(sd.value) as max_value,
        COUNT(*) as reading_count,
        COUNT(CASE WHEN check_sensor_anomaly(p_device_id, sd.sensor_type, sd.value) THEN 1 END) as anomaly_count
    FROM iot_sensor_data sd
    WHERE sd.device_id = p_device_id
        AND sd.timestamp BETWEEN p_start_time AND p_end_time
    GROUP BY sd.sensor_type;
END;
$$;
