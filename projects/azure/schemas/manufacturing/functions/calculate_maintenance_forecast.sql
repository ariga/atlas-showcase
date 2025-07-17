-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/equipment.sql
-- atlas:import ../tables/maintenance_work_orders.sql
-- atlas:import ../types/enum_maintenance_type.sql
-- atlas:import ../../public/types/enum_priority_level.sql

-- create "calculate_maintenance_forecast" function
CREATE FUNCTION "manufacturing"."calculate_maintenance_forecast" ("p_equipment_id" integer DEFAULT NULL::integer, "p_forecast_months" integer DEFAULT 6) RETURNS TABLE ("equipment_id" integer, "equipment_name" character varying, "maintenance_type" "manufacturing"."maintenance_type", "predicted_date" date, "confidence_level" numeric, "estimated_cost" numeric, "priority_level" "public"."priority_level") LANGUAGE plpgsql AS $$
DECLARE
    v_equipment_filter TEXT := '';
BEGIN
    -- Build equipment filter
    IF p_equipment_id IS NOT NULL THEN
        v_equipment_filter := ' AND e.id = ' || p_equipment_id;
    END IF;
    
    RETURN QUERY EXECUTE format('
        WITH equipment_maintenance_patterns AS (
            SELECT 
                e.id as equipment_id,
                e.name as equipment_name,
                e.last_maintenance,
                e.next_maintenance,
                -- Calculate average time between maintenance based on history
                COALESCE(
                    AVG(EXTRACT(DAYS FROM (wo.actual_end - LAG(wo.actual_end) OVER (
                        PARTITION BY e.id, wo.maintenance_type 
                        ORDER BY wo.actual_end
                    )))), 90
                ) as avg_days_between_maintenance,
                wo.maintenance_type,
                AVG(wo.actual_cost) as avg_cost,
                COUNT(*) as historical_count
            FROM manufacturing.equipment e
            LEFT JOIN manufacturing.maintenance_work_orders wo ON e.id = wo.equipment_id
                AND wo.status = ''completed''
                AND wo.actual_end >= CURRENT_DATE - INTERVAL ''2 years''
            WHERE 1=1 %s
            GROUP BY e.id, e.name, e.last_maintenance, e.next_maintenance, wo.maintenance_type
        ),
        forecasted_maintenance AS (
            SELECT 
                emp.equipment_id,
                emp.equipment_name,
                emp.maintenance_type,
                -- Predict next maintenance date
                CASE 
                    WHEN emp.maintenance_type = ''preventive'' THEN
                        COALESCE(emp.next_maintenance::DATE, 
                                CURRENT_DATE + (emp.avg_days_between_maintenance || '' days'')::INTERVAL)
                    WHEN emp.maintenance_type = ''corrective'' THEN
                        -- Predict based on equipment age and failure patterns
                        CURRENT_DATE + (emp.avg_days_between_maintenance * 0.8 || '' days'')::INTERVAL
                    ELSE
                        CURRENT_DATE + (emp.avg_days_between_maintenance || '' days'')::INTERVAL
                END::DATE as predicted_date,
                -- Calculate confidence based on historical data availability
                CASE 
                    WHEN emp.historical_count >= 5 THEN 0.85
                    WHEN emp.historical_count >= 3 THEN 0.70
                    WHEN emp.historical_count >= 1 THEN 0.55
                    ELSE 0.40
                END as confidence_level,
                COALESCE(emp.avg_cost, 
                    CASE emp.maintenance_type
                        WHEN ''preventive'' THEN 500.00
                        WHEN ''corrective'' THEN 1500.00
                        WHEN ''predictive'' THEN 300.00
                        WHEN ''emergency'' THEN 2500.00
                        ELSE 800.00
                    END
                ) as estimated_cost,
                CASE emp.maintenance_type
                    WHEN ''emergency'' THEN ''high''::public.priority_level
                    WHEN ''corrective'' THEN ''high''::public.priority_level  
                    WHEN ''preventive'' THEN ''medium''::public.priority_level
                    ELSE ''low''::public.priority_level
                END as priority_level
            FROM equipment_maintenance_patterns emp
            WHERE emp.maintenance_type IS NOT NULL
        )
        SELECT 
            fm.equipment_id,
            fm.equipment_name,
            fm.maintenance_type,
            fm.predicted_date,
            fm.confidence_level,
            fm.estimated_cost,
            fm.priority_level
        FROM forecasted_maintenance fm
        WHERE fm.predicted_date <= CURRENT_DATE + INTERVAL ''%s months''
        ORDER BY fm.predicted_date ASC, fm.priority_level DESC, fm.equipment_id
    ', v_equipment_filter, p_forecast_months);
END;
$$;
