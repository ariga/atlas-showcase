-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/production_lines.sql
-- atlas:import ../tables/production_runs.sql

-- create "production_line_efficiency" view
CREATE VIEW "manufacturing"."production_line_efficiency" (
  "production_line_id",
  "production_line_name",
  "capacity_per_hour",
  "total_runs",
  "total_output",
  "avg_output_per_run",
  "efficiency_percentage",
  "quality_pass_rate"
) AS SELECT pl.id AS production_line_id,
    pl.name AS production_line_name,
    pl.capacity_per_hour,
    count(pr.id) AS total_runs,
    sum(pr.actual_quantity) AS total_output,
    avg(pr.actual_quantity) AS avg_output_per_run,
    sum(pr.actual_quantity)::numeric / NULLIF(pl.capacity_per_hour::numeric * EXTRACT(epoch FROM max(pr.end_time) - min(pr.start_time)) / 3600::numeric, 0::numeric) * 100::numeric AS efficiency_percentage,
    count(
        CASE
            WHEN pr.quality_status = 'pass'::manufacturing.quality_status THEN 1
            ELSE NULL::integer
        END) / NULLIF(count(pr.id), 0) * 100 AS quality_pass_rate
   FROM manufacturing.production_lines pl
     LEFT JOIN manufacturing.production_runs pr ON pl.id = pr.production_line_id AND pr.start_time >= (CURRENT_DATE - '30 days'::interval) AND pr.end_time IS NOT NULL
  GROUP BY pl.id, pl.name, pl.capacity_per_hour;
