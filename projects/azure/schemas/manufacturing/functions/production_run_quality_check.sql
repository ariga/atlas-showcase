-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/equipment.sql
-- atlas:import ../tables/production_lines.sql

-- create "production_run_quality_check" function
CREATE FUNCTION "manufacturing"."production_run_quality_check" () RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
    v_line_name VARCHAR;
    v_equipment_count INTEGER;
    v_available_equipment INTEGER;
BEGIN
    -- Auto-calculate quality metrics when production run completes
    IF NEW.end_time IS NOT NULL AND OLD.end_time IS NULL THEN
        -- Calculate yield percentage
        IF NEW.planned_quantity > 0 THEN
            NEW.yield_percentage := (NEW.actual_quantity::NUMERIC / NEW.planned_quantity) * 100;
        END IF;
        
        -- Auto-set quality status based on yield
        IF NEW.quality_status = 'pending' THEN
            NEW.quality_status := CASE 
                WHEN NEW.yield_percentage >= 95 THEN 'pass'
                WHEN NEW.yield_percentage >= 80 THEN 'rework'
                ELSE 'fail'
            END;
        END IF;
        
        -- Update production line last run timestamp
        UPDATE manufacturing.production_lines 
        SET last_production_run = NEW.end_time
        WHERE id = NEW.production_line_id;
    END IF;
    
    -- Validate production run constraints
    IF NEW.start_time IS NOT NULL AND NEW.end_time IS NOT NULL THEN
        -- Check for equipment availability during run
        SELECT 
            COUNT(*),
            COUNT(CASE WHEN status IN ('available', 'running') THEN 1 END)
        INTO v_equipment_count, v_available_equipment
        FROM manufacturing.equipment
        WHERE production_line_id = NEW.production_line_id;
        
        IF v_available_equipment = 0 THEN
            RAISE EXCEPTION 'Cannot complete production run - no equipment available on line';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;
