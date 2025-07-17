-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/production_runs.sql

-- create "daily_production_summary" view
CREATE MATERIALIZED VIEW "manufacturing"."daily_production_summary" (
  "production_date",
  "active_lines",
  "total_runs",
  "unique_products",
  "planned_output",
  "actual_output",
  "overall_yield",
  "quality_pass_count",
  "quality_fail_count",
  "rework_count",
  "avg_run_duration_hours",
  "extended_runs",
  "products_produced"
) AS SELECT date(start_time) AS production_date,
    count(DISTINCT production_line_id) AS active_lines,
    count(*) AS total_runs,
    count(DISTINCT product_code) AS unique_products,
    sum(planned_quantity) AS planned_output,
    sum(actual_quantity) AS actual_output,
    ((sum(actual_quantity) / NULLIF(sum(planned_quantity), 0)) * 100) AS overall_yield,
    count(
        CASE
            WHEN (quality_status = 'pass'::manufacturing.quality_status) THEN 1
            ELSE NULL::integer
        END) AS quality_pass_count,
    count(
        CASE
            WHEN (quality_status = 'fail'::manufacturing.quality_status) THEN 1
            ELSE NULL::integer
        END) AS quality_fail_count,
    count(
        CASE
            WHEN (quality_status = 'rework'::manufacturing.quality_status) THEN 1
            ELSE NULL::integer
        END) AS rework_count,
    avg((EXTRACT(epoch FROM (end_time - start_time)) / (3600)::numeric)) AS avg_run_duration_hours,
    count(
        CASE
            WHEN (end_time > (start_time + '08:00:00'::interval)) THEN 1
            ELSE NULL::integer
        END) AS extended_runs,
    string_agg(DISTINCT (product_code)::text, ', '::text ORDER BY (product_code)::text) AS products_produced
   FROM manufacturing.production_runs pr
  WHERE ((start_time >= (CURRENT_DATE - '90 days'::interval)) AND (end_time IS NOT NULL))
  GROUP BY (date(start_time));
