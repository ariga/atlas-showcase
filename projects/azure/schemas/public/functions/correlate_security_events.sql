-- atlas:import ../public.sql
-- atlas:import ../tables/security_events.sql
-- atlas:import ../types/enum_security_event_type.sql

-- create "correlate_security_events" function
CREATE FUNCTION "public"."correlate_security_events" ("p_user_id" integer, "p_time_window" interval DEFAULT '01:00:00'::interval) RETURNS TABLE ("event_type" "public"."security_event_type", "event_count" bigint, "unique_ips" bigint, "severity_distribution" jsonb) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        se.event_type,
        COUNT(*) as event_count,
        COUNT(DISTINCT se.ip_address) as unique_ips,
        jsonb_object_agg(se.severity, severity_count) as severity_distribution
    FROM security_events se
    WHERE se.user_id = p_user_id
        AND se.created_at >= CURRENT_TIMESTAMP - p_time_window
    GROUP BY se.event_type
    HAVING COUNT(*) > 1;
END;
$$;
