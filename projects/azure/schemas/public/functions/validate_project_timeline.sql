-- atlas:import ../public.sql
-- atlas:import ../tables/projects.sql

-- create "validate_project_timeline" function
CREATE FUNCTION "public"."validate_project_timeline" () RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    -- Ensure planned dates are valid
    IF NEW.planned_end < NEW.planned_start THEN
        RAISE EXCEPTION 'Planned end date must be after planned start date';
    END IF;
    
    -- Ensure actual dates are valid if provided
    IF NEW.actual_start IS NOT NULL AND NEW.actual_end IS NOT NULL THEN
        IF NEW.actual_end < NEW.actual_start THEN
            RAISE EXCEPTION 'Actual end date must be after actual start date';
        END IF;
    END IF;
    
    -- Check parent project dates if applicable
    IF NEW.parent_project_id IS NOT NULL THEN
        DECLARE
            parent_start date;
            parent_end date;
        BEGIN
            SELECT planned_start, planned_end INTO parent_start, parent_end
            FROM projects WHERE id = NEW.parent_project_id;
            
            IF NEW.planned_start < parent_start OR NEW.planned_end > parent_end THEN
                RAISE EXCEPTION 'Sub-project dates must be within parent project timeline';
            END IF;
        END;
    END IF;
    
    RETURN NEW;
END;
$$;
