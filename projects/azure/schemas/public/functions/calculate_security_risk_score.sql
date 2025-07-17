-- atlas:import ../public.sql
-- atlas:import ../tables/security_events.sql

-- create "calculate_security_risk_score" function
CREATE FUNCTION "public"."calculate_security_risk_score" ("p_user_id" integer) RETURNS integer LANGUAGE plpgsql AS $$
DECLARE
    v_risk_score INTEGER := 0;
    v_failed_logins INTEGER;
    v_policy_violations INTEGER;
    v_critical_events INTEGER;
BEGIN
    -- Count failed login attempts in last 24 hours
    SELECT COUNT(*) INTO v_failed_logins
    FROM security_events
    WHERE user_id = p_user_id
        AND event_type = 'login_attempt'
        AND (event_data->>'success')::boolean = false
        AND created_at >= CURRENT_TIMESTAMP - INTERVAL '24 hours';
    
    -- Count policy violations in last 7 days
    SELECT COUNT(*) INTO v_policy_violations
    FROM security_events
    WHERE user_id = p_user_id
        AND event_type = 'policy_violation'
        AND created_at >= CURRENT_TIMESTAMP - INTERVAL '7 days';
    
    -- Count critical events in last 30 days
    SELECT COUNT(*) INTO v_critical_events
    FROM security_events
    WHERE user_id = p_user_id
        AND severity = 'critical'
        AND created_at >= CURRENT_TIMESTAMP - INTERVAL '30 days';
    
    -- Calculate risk score
    v_risk_score := 
        (v_failed_logins * 10) +
        (v_policy_violations * 20) +
        (v_critical_events * 50);
    
    RETURN LEAST(v_risk_score, 100); -- Cap at 100
END;
$$;
