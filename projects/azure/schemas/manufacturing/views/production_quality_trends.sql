-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/production_lines.sql
-- atlas:import ../tables/production_runs.sql

-- create "production_quality_trends" view
CREATE VIEW "manufacturing"."production_quality_trends" (
  "production_date",
  "production_line_name",
  "product_code",
  "total_batches",
  "planned_total",
  "actual_total",
  "yield_percentage",
  "passed_batches",
  "failed_batches",
  "rework_batches",
  "pass_rate",
  "avg_batch_hours"
) AS SELECT date_trunc('day'::text, pr.created_at) AS production_date,
    pl.name AS production_line_name,
    pr.product_code,
    count(*) AS total_batches,
    sum(pr.planned_quantity) AS planned_total,
    sum(pr.actual_quantity) AS actual_total,
    sum(pr.actual_quantity) / NULLIF(sum(pr.planned_quantity), 0) * 100 AS yield_percentage,
    count(
        CASE
            WHEN pr.quality_status = 'pass'::manufacturing.quality_status THEN 1
            ELSE NULL::integer
        END) AS passed_batches,
    count(
        CASE
            WHEN pr.quality_status = 'fail'::manufacturing.quality_status THEN 1
            ELSE NULL::integer
        END) AS failed_batches,
    count(
        CASE
            WHEN pr.quality_status = 'rework'::manufacturing.quality_status THEN 1
            ELSE NULL::integer
        END) AS rework_batches,
    count(
        CASE
            WHEN pr.quality_status = 'pass'::manufacturing.quality_status THEN 1
            ELSE NULL::integer
        END) / NULLIF(count(*), 0) * 100 AS pass_rate,
    avg(EXTRACT(epoch FROM pr.end_time - pr.start_time) / 3600::numeric) AS avg_batch_hours
   FROM manufacturing.production_runs pr
     JOIN manufacturing.production_lines pl ON pr.production_line_id = pl.id
  WHERE pr.created_at >= (CURRENT_DATE - '90 days'::interval) AND pr.end_time IS NOT NULL
  GROUP BY (date_trunc('day'::text, pr.created_at)), pl.name, pr.product_code;
