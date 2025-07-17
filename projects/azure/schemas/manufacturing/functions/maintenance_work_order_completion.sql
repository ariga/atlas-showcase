-- atlas:import auto_assign_technician.sql
-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/equipment.sql
-- atlas:import ../tables/maintenance_performance_metrics.sql

-- create "maintenance_work_order_completion" function
CREATE FUNCTION "manufacturing"."maintenance_work_order_completion" () RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
    v_equipment_id INTEGER;
    v_maintenance_type manufacturing.maintenance_type;
BEGIN
    -- Handle work order completion
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        -- Update equipment last maintenance date
        UPDATE manufacturing.equipment 
        SET 
            last_maintenance = NEW.actual_end,
            -- For preventive maintenance, schedule next maintenance
            next_maintenance = CASE 
                WHEN NEW.maintenance_type = 'preventive' THEN 
                    NEW.actual_end + INTERVAL '90 days'
                ELSE next_maintenance
            END
        WHERE id = NEW.equipment_id;
        
        -- Auto-change equipment status back to available if it was in maintenance
        UPDATE manufacturing.equipment 
        SET status = 'available'
        WHERE id = NEW.equipment_id 
            AND status = 'maintenance';
            
        -- Calculate actual vs estimated variance for future planning
        IF NEW.estimated_hours > 0 AND NEW.actual_hours > 0 THEN
            INSERT INTO manufacturing.maintenance_performance_metrics (
                work_order_id,
                equipment_id,
                maintenance_type,
                estimated_hours,
                actual_hours,
                hours_variance_pct,
                completion_date
            ) VALUES (
                NEW.id,
                NEW.equipment_id,
                NEW.maintenance_type,
                NEW.estimated_hours,
                NEW.actual_hours,
                ((NEW.actual_hours - NEW.estimated_hours) / NEW.estimated_hours) * 100,
                NEW.actual_end
            );
        END IF;
    END IF;
    
    -- Auto-assign work order if technician is null and status changes to scheduled
    IF NEW.status = 'scheduled' AND NEW.assigned_technician_id IS NULL THEN
        NEW.assigned_technician_id := manufacturing.auto_assign_technician(NEW.id);
    END IF;
    
    RETURN NEW;
END;
$$;
