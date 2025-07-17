-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/production_runs.sql

-- create "calculate_oee" function
CREATE FUNCTION "manufacturing"."calculate_oee" ("p_production_line_id" integer, "p_calculation_date" date DEFAULT CURRENT_DATE) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
    v_planned_hours NUMERIC := 24; -- Assume 24-hour operation
    v_actual_production_hours NUMERIC;
    v_total_pieces_produced INTEGER;
    v_total_planned_pieces INTEGER;
    v_total_quality_pieces INTEGER;
    v_availability NUMERIC(5,2);
    v_performance NUMERIC(5,2);
    v_quality NUMERIC(5,2);
    v_oee NUMERIC(5,2);
    v_result JSONB;
BEGIN
    -- Get production data for the date
    SELECT 
        COALESCE(SUM(EXTRACT(EPOCH FROM (end_time - start_time)) / 3600), 0),
        COALESCE(SUM(actual_quantity), 0),
        COALESCE(SUM(planned_quantity), 0),
        COALESCE(SUM(CASE WHEN quality_status = 'pass' THEN actual_quantity ELSE 0 END), 0)
    INTO 
        v_actual_production_hours,
        v_total_pieces_produced,
        v_total_planned_pieces,
        v_total_quality_pieces
    FROM manufacturing.production_runs pr
    WHERE pr.production_line_id = p_production_line_id
        AND DATE(pr.start_time) = p_calculation_date
        AND pr.end_time IS NOT NULL;
    
    -- Calculate Availability (actual production time / planned production time)
    v_availability := CASE 
        WHEN v_planned_hours > 0 THEN 
            LEAST((v_actual_production_hours / v_planned_hours) * 100, 100)
        ELSE 0 
    END;
    
    -- Calculate Performance (actual production / planned production)
    v_performance := CASE 
        WHEN v_total_planned_pieces > 0 THEN 
            LEAST((v_total_pieces_produced::NUMERIC / v_total_planned_pieces) * 100, 100)
        ELSE 0 
    END;
    
    -- Calculate Quality (quality pieces / total pieces)
    v_quality := CASE 
        WHEN v_total_pieces_produced > 0 THEN 
            (v_total_quality_pieces::NUMERIC / v_total_pieces_produced) * 100
        ELSE 0 
    END;
    
    -- Calculate Overall Equipment Effectiveness (OEE)
    v_oee := (v_availability * v_performance * v_quality) / 10000;
    
    -- Build result JSON
    v_result := jsonb_build_object(
        'calculation_date', p_calculation_date,
        'production_line_id', p_production_line_id,
        'planned_hours', v_planned_hours,
        'actual_production_hours', v_actual_production_hours,
        'total_pieces_produced', v_total_pieces_produced,
        'total_planned_pieces', v_total_planned_pieces,
        'total_quality_pieces', v_total_quality_pieces,
        'availability_pct', v_availability,
        'performance_pct', v_performance,
        'quality_pct', v_quality,
        'oee_pct', v_oee,
        'oee_class', CASE 
            WHEN v_oee >= 85 THEN 'world_class'
            WHEN v_oee >= 60 THEN 'acceptable'
            WHEN v_oee >= 40 THEN 'needs_improvement'
            ELSE 'poor'
        END
    );
    
    RETURN v_result;
END;
$$;
