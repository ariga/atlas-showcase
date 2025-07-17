-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/maintenance_work_orders.sql
-- atlas:import ../../public/tables/user_roles.sql
-- atlas:import ../../public/tables/users.sql

-- create "auto_assign_technician" function
CREATE FUNCTION "manufacturing"."auto_assign_technician" ("p_work_order_id" integer, "p_preferred_skills" text[] DEFAULT NULL::text[]) RETURNS integer LANGUAGE plpgsql AS $$
DECLARE
    v_assigned_technician_id INTEGER;
    v_maintenance_type manufacturing.maintenance_type;
    v_priority_level public.priority_level;
    v_estimated_hours NUMERIC;
BEGIN
    -- Get work order details
    SELECT maintenance_type, priority_level, estimated_hours
    INTO v_maintenance_type, v_priority_level, v_estimated_hours
    FROM manufacturing.maintenance_work_orders
    WHERE id = p_work_order_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Work order with ID % not found', p_work_order_id;
    END IF;
    
    -- Find available technician with lowest current workload
    -- This is a simplified algorithm - in practice you'd consider skills, certifications, etc.
    WITH technician_workload AS (
        SELECT 
            u.id as technician_id,
            u.first_name || ' ' || u.last_name as technician_name,
            COALESCE(SUM(
                CASE WHEN wo.status IN ('planned', 'scheduled', 'in_progress') 
                THEN wo.estimated_hours ELSE 0 END
            ), 0) as current_workload_hours,
            COUNT(CASE WHEN wo.maintenance_type = v_maintenance_type THEN 1 END) as experience_count
        FROM public.users u
        LEFT JOIN manufacturing.maintenance_work_orders wo ON u.id = wo.assigned_technician_id
            AND wo.created_at >= CURRENT_DATE - INTERVAL '6 months'
        WHERE u.status = 'active'
            AND EXISTS (
                SELECT 1 FROM public.user_roles ur 
                WHERE ur.user_id = u.id 
                AND ur.role_type IN ('ENG', 'Tech Lead')
            )
        GROUP BY u.id, u.first_name, u.last_name
    )
    SELECT technician_id
    INTO v_assigned_technician_id
    FROM technician_workload
    WHERE current_workload_hours <= 40 -- Max 40 hours of pending work
    ORDER BY 
        CASE WHEN v_priority_level = 'high' THEN current_workload_hours ELSE experience_count END,
        current_workload_hours ASC,
        experience_count DESC
    LIMIT 1;
    
    -- If no technician found, assign to least busy one regardless of workload
    IF v_assigned_technician_id IS NULL THEN
        WITH technician_workload AS (
            SELECT 
                u.id as technician_id,
                COALESCE(SUM(
                    CASE WHEN wo.status IN ('planned', 'scheduled', 'in_progress') 
                    THEN wo.estimated_hours ELSE 0 END
                ), 0) as current_workload_hours
            FROM public.users u
            LEFT JOIN manufacturing.maintenance_work_orders wo ON u.id = wo.assigned_technician_id
            WHERE u.status = 'active'
                AND EXISTS (
                    SELECT 1 FROM public.user_roles ur 
                    WHERE ur.user_id = u.id 
                    AND ur.role_type IN ('ENG', 'Tech Lead')
                )
            GROUP BY u.id
        )
        SELECT technician_id
        INTO v_assigned_technician_id
        FROM technician_workload
        ORDER BY current_workload_hours ASC
        LIMIT 1;
    END IF;
    
    -- Update work order with assigned technician
    IF v_assigned_technician_id IS NOT NULL THEN
        UPDATE manufacturing.maintenance_work_orders
        SET 
            assigned_technician_id = v_assigned_technician_id,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = p_work_order_id;
    END IF;
    
    RETURN v_assigned_technician_id;
END;
$$;
