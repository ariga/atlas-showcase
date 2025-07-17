-- atlas:import ../public.sql
-- atlas:import ../tables/security_events.sql
-- atlas:import ../tables/security_incidents.sql
-- atlas:import ../tables/users.sql

-- create "check_security_threshold" function
CREATE FUNCTION "public"."check_security_threshold" () RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
    v_event_count INTEGER;
BEGIN
    -- Check for suspicious activity patterns
    SELECT COUNT(*) INTO v_event_count
    FROM security_events
    WHERE user_id = NEW.user_id
        AND event_type = NEW.event_type
        AND created_at >= CURRENT_TIMESTAMP - INTERVAL '5 minutes';
    
    -- If more than 10 similar events in 5 minutes, escalate
    IF v_event_count > 10 AND NEW.severity != 'critical' THEN
        NEW.severity = 'critical';
        
        -- Create incident if not exists
        INSERT INTO security_incidents (
            incident_number,
            title,
            severity,
            affected_users
        ) VALUES (
            'INC-' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD-HH24MISS'),
            'Suspicious activity detected for user ' || NEW.user_id,
            'critical',
            ARRAY[NEW.user_id]
        ) ON CONFLICT DO NOTHING;
    END IF;
    
    RETURN NEW;
END;
$$;
