-- atlas:import ../public.sql
-- atlas:import ../tables/iot_sensor_types.sql
-- atlas:import ../types/enum_sensor_type.sql

-- create "check_sensor_anomaly" function
CREATE FUNCTION "public"."check_sensor_anomaly" ("p_device_id" integer, "p_sensor_type" "public"."sensor_type", "p_value" numeric) RETURNS boolean LANGUAGE plpgsql AS $$
DECLARE
    v_threshold JSONB;
    v_min_value DECIMAL;
    v_max_value DECIMAL;
BEGIN
    SELECT alert_thresholds, min_value, max_value
    INTO v_threshold, v_min_value, v_max_value
    FROM iot_sensor_types
    WHERE sensor_type = p_sensor_type;
    
    IF p_value < v_min_value OR p_value > v_max_value THEN
        RETURN TRUE;
    END IF;
    
    IF v_threshold IS NOT NULL THEN
        IF p_value < (v_threshold->>'critical_min')::DECIMAL OR 
           p_value > (v_threshold->>'critical_max')::DECIMAL THEN
            RETURN TRUE;
        END IF;
    END IF;
    
    RETURN FALSE;
END;
$$;
