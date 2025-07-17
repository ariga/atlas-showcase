-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/production_runs.sql

-- create "calculate_production_efficiency" function
CREATE FUNCTION "manufacturing"."calculate_production_efficiency" ("p_production_line_id" integer, "p_start_date" date DEFAULT (CURRENT_DATE - '30 days'::interval), "p_end_date" date DEFAULT CURRENT_DATE) RETURNS numeric LANGUAGE plpgsql AS $$
DECLARE
    v_total_planned NUMERIC;
    v_total_actual NUMERIC;
    v_efficiency NUMERIC(5,2);
BEGIN
    SELECT 
        COALESCE(SUM(planned_quantity), 0),
        COALESCE(SUM(actual_quantity), 0)
    INTO v_total_planned, v_total_actual
    FROM manufacturing.production_runs pr
    WHERE pr.production_line_id = p_production_line_id
        AND DATE(pr.start_time) BETWEEN p_start_date AND p_end_date
        AND pr.end_time IS NOT NULL;
    
    IF v_total_planned = 0 THEN
        RETURN 0;
    END IF;
    
    v_efficiency := (v_total_actual / v_total_planned) * 100;
    
    RETURN LEAST(v_efficiency, 100.00);
END;
$$;
