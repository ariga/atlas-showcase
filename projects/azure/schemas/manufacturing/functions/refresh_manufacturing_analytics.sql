-- atlas:import ../manufacturing.sql
-- atlas:import ../views/daily_production_summary.sql
-- atlas:import ../views/equipment_health_dashboard.sql
-- atlas:import ../views/equipment_utilization_matrix.sql
-- atlas:import ../views/maintenance_workload_analysis.sql
-- atlas:import ../views/manufacturing_cost_analysis.sql

-- create "refresh_manufacturing_analytics" function
CREATE FUNCTION "manufacturing"."refresh_manufacturing_analytics" () RETURNS void LANGUAGE plpgsql AS $$
DECLARE
    v_start_time TIMESTAMPTZ;
    v_refresh_count INTEGER := 0;
BEGIN
    v_start_time := CURRENT_TIMESTAMP;
    
    -- Refresh materialized views in dependency order
    
    -- 1. Equipment health dashboard (no dependencies)
    REFRESH MATERIALIZED VIEW manufacturing.equipment_health_dashboard;
    v_refresh_count := v_refresh_count + 1;
    
    -- 2. Maintenance workload analysis (no dependencies)
    REFRESH MATERIALIZED VIEW manufacturing.maintenance_workload_analysis;
    v_refresh_count := v_refresh_count + 1;
    
    -- 3. Equipment utilization matrix (depends on production data)
    REFRESH MATERIALIZED VIEW manufacturing.equipment_utilization_matrix;
    v_refresh_count := v_refresh_count + 1;
    
    -- 4. Daily production summary (no dependencies)
    REFRESH MATERIALIZED VIEW manufacturing.daily_production_summary;
    v_refresh_count := v_refresh_count + 1;
    
    -- 5. Manufacturing cost analysis (depends on multiple sources)
    REFRESH MATERIALIZED VIEW manufacturing.manufacturing_cost_analysis;
    v_refresh_count := v_refresh_count + 1;
    
    -- Log the refresh operation (could extend to create audit table)
    RAISE NOTICE 'Manufacturing analytics refresh completed. Views refreshed: %, Duration: %', 
        v_refresh_count, 
        EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - v_start_time)) || ' seconds';
        
    -- Optional: Could insert into an audit/log table here
    /*
    INSERT INTO manufacturing.analytics_refresh_log (
        refresh_timestamp,
        views_refreshed,
        duration_seconds,
        status
    ) VALUES (
        v_start_time,
        v_refresh_count,
        EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - v_start_time)),
        'completed'
    );
    */
END;
$$;
