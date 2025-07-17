-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/production_lines.sql
-- atlas:import ../tables/production_runs.sql

-- create "generate_production_forecast" function
CREATE FUNCTION "manufacturing"."generate_production_forecast" ("p_production_line_id" integer, "p_product_code" character varying, "p_forecast_days" integer DEFAULT 30) RETURNS jsonb LANGUAGE plpgsql AS $$
DECLARE
    v_historical_avg NUMERIC;
    v_trend_factor NUMERIC;
    v_seasonal_factor NUMERIC;
    v_capacity_limit INTEGER;
    v_forecast_quantity INTEGER;
    v_confidence_level NUMERIC(3,2);
    v_result JSONB;
BEGIN
    -- Get production line capacity
    SELECT capacity_per_hour * 24 -- Daily capacity assuming 24-hour operation
    INTO v_capacity_limit
    FROM manufacturing.production_lines
    WHERE id = p_production_line_id;
    
    -- Calculate historical average daily production for the product
    SELECT COALESCE(AVG(daily_production), 0)
    INTO v_historical_avg
    FROM (
        SELECT 
            DATE(start_time) as production_date,
            SUM(actual_quantity) as daily_production
        FROM manufacturing.production_runs
        WHERE production_line_id = p_production_line_id
            AND product_code = p_product_code
            AND start_time >= CURRENT_DATE - INTERVAL '90 days'
            AND end_time IS NOT NULL
        GROUP BY DATE(start_time)
    ) daily_stats;
    
    -- Calculate trend factor (simplified linear trend)
    SELECT COALESCE(
        (SELECT 
            CASE 
                WHEN COUNT(*) >= 14 THEN
                    (AVG(CASE WHEN production_date >= CURRENT_DATE - INTERVAL '14 days' THEN daily_production END) /
                     NULLIF(AVG(CASE WHEN production_date < CURRENT_DATE - INTERVAL '14 days' THEN daily_production END), 0))
                ELSE 1.0
            END
        FROM (
            SELECT 
                DATE(start_time) as production_date,
                SUM(actual_quantity) as daily_production
            FROM manufacturing.production_runs
            WHERE production_line_id = p_production_line_id
                AND product_code = p_product_code
                AND start_time >= CURRENT_DATE - INTERVAL '28 days'
                AND end_time IS NOT NULL
            GROUP BY DATE(start_time)
        ) trend_data), 1.0
    ) INTO v_trend_factor;
    
    -- Simplified seasonal factor (could be enhanced with more sophisticated analysis)
    v_seasonal_factor := 1.0 + (EXTRACT(DOW FROM CURRENT_DATE) - 3.5) * 0.02; -- Slight weekday variation
    
    -- Calculate forecast
    v_forecast_quantity := LEAST(
        (v_historical_avg * v_trend_factor * v_seasonal_factor * p_forecast_days)::INTEGER,
        v_capacity_limit * p_forecast_days
    );
    
    -- Calculate confidence level based on historical data availability and variance
    SELECT CASE 
        WHEN COUNT(*) >= 30 THEN 
            GREATEST(0.60, 1.0 - (STDDEV(daily_production) / NULLIF(AVG(daily_production), 0)))
        WHEN COUNT(*) >= 14 THEN 0.70
        WHEN COUNT(*) >= 7 THEN 0.60
        ELSE 0.50
    END
    INTO v_confidence_level
    FROM (
        SELECT 
            DATE(start_time) as production_date,
            SUM(actual_quantity) as daily_production
        FROM manufacturing.production_runs
        WHERE production_line_id = p_production_line_id
            AND product_code = p_product_code
            AND start_time >= CURRENT_DATE - INTERVAL '90 days'
            AND end_time IS NOT NULL
        GROUP BY DATE(start_time)
    ) variance_calc;
    
    -- Build result
    v_result := jsonb_build_object(
        'production_line_id', p_production_line_id,
        'product_code', p_product_code,
        'forecast_period_days', p_forecast_days,
        'historical_daily_avg', ROUND(v_historical_avg, 2),
        'trend_factor', ROUND(v_trend_factor, 3),
        'seasonal_factor', ROUND(v_seasonal_factor, 3),
        'forecasted_quantity', v_forecast_quantity,
        'capacity_limit_total', v_capacity_limit * p_forecast_days,
        'capacity_utilization_pct', ROUND((v_forecast_quantity::NUMERIC / NULLIF(v_capacity_limit * p_forecast_days, 0)) * 100, 2),
        'confidence_level', v_confidence_level,
        'forecast_generated_at', CURRENT_TIMESTAMP
    );
    
    RETURN v_result;
END;
$$;
