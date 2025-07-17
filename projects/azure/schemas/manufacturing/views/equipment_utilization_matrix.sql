-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/equipment.sql
-- atlas:import ../tables/maintenance_work_orders.sql
-- atlas:import ../tables/production_lines.sql
-- atlas:import ../tables/production_runs.sql

-- create "equipment_utilization_matrix" view
CREATE MATERIALIZED VIEW "manufacturing"."equipment_utilization_matrix" (
  "equipment_id",
  "equipment_name",
  "equipment_type",
  "production_line_name",
  "month",
  "production_hours",
  "maintenance_hours",
  "total_month_hours",
  "production_utilization_pct",
  "maintenance_utilization_pct",
  "total_utilization_pct"
) AS WITH equipment_hours AS (
         SELECT e.id AS equipment_id,
            e.name AS equipment_name,
            e.equipment_type,
            pl.name AS production_line_name,
            date_trunc('month'::text, pr.start_time) AS month,
            sum((EXTRACT(epoch FROM (pr.end_time - pr.start_time)) / (3600)::numeric)) AS production_hours,
            sum(wo.actual_hours) AS maintenance_hours,
            ((24)::numeric * EXTRACT(days FROM ((date_trunc('month'::text, pr.start_time) + '1 mon'::interval) - date_trunc('month'::text, pr.start_time)))) AS total_month_hours
           FROM (((manufacturing.equipment e
             JOIN manufacturing.production_lines pl ON ((e.production_line_id = pl.id)))
             LEFT JOIN manufacturing.production_runs pr ON (((pl.id = pr.production_line_id) AND (pr.start_time >= (CURRENT_DATE - '1 year'::interval)) AND (pr.end_time IS NOT NULL))))
             LEFT JOIN manufacturing.maintenance_work_orders wo ON (((e.id = wo.equipment_id) AND (wo.actual_start >= (CURRENT_DATE - '1 year'::interval)) AND (wo.actual_end IS NOT NULL))))
          GROUP BY e.id, e.name, e.equipment_type, pl.name, (date_trunc('month'::text, pr.start_time))
        )
 SELECT equipment_id,
    equipment_name,
    equipment_type,
    production_line_name,
    month,
    production_hours,
    maintenance_hours,
    total_month_hours,
    ((production_hours / NULLIF(total_month_hours, (0)::numeric)) * (100)::numeric) AS production_utilization_pct,
    ((maintenance_hours / NULLIF(total_month_hours, (0)::numeric)) * (100)::numeric) AS maintenance_utilization_pct,
    (((production_hours + COALESCE(maintenance_hours, (0)::numeric)) / NULLIF(total_month_hours, (0)::numeric)) * (100)::numeric) AS total_utilization_pct
   FROM equipment_hours
  WHERE (month IS NOT NULL);
