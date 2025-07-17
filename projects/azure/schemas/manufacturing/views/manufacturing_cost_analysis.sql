-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/equipment.sql
-- atlas:import ../tables/maintenance_work_orders.sql
-- atlas:import ../tables/production_lines.sql
-- atlas:import ../tables/production_runs.sql

-- create "manufacturing_cost_analysis" view
CREATE MATERIALIZED VIEW "manufacturing"."manufacturing_cost_analysis" (
  "month",
  "production_line_id",
  "production_line_name",
  "product_code",
  "total_output",
  "production_runs",
  "estimated_labor_cost",
  "maintenance_costs",
  "equipment_depreciation",
  "total_costs",
  "cost_per_unit",
  "avg_production_hours"
) AS WITH cost_breakdown AS (
         SELECT date_trunc('month'::text, pr.start_time) AS month,
            pl.id AS production_line_id,
            pl.name AS production_line_name,
            pr.product_code,
            sum(pr.actual_quantity) AS total_output,
            count(*) AS production_runs,
            ((count(*) * 8) * 50) AS estimated_labor_cost,
            sum(wo.actual_cost) AS maintenance_costs,
            (count(DISTINCT e.id) * 1000) AS equipment_depreciation,
            avg((EXTRACT(epoch FROM (pr.end_time - pr.start_time)) / (3600)::numeric)) AS avg_production_hours
           FROM (((manufacturing.production_runs pr
             JOIN manufacturing.production_lines pl ON ((pr.production_line_id = pl.id)))
             JOIN manufacturing.equipment e ON ((pl.id = e.production_line_id)))
             LEFT JOIN manufacturing.maintenance_work_orders wo ON (((e.id = wo.equipment_id) AND (date_trunc('month'::text, wo.actual_start) = date_trunc('month'::text, pr.start_time)))))
          WHERE ((pr.start_time >= (CURRENT_DATE - '2 years'::interval)) AND (pr.end_time IS NOT NULL))
          GROUP BY (date_trunc('month'::text, pr.start_time)), pl.id, pl.name, pr.product_code
        )
 SELECT month,
    production_line_id,
    production_line_name,
    product_code,
    total_output,
    production_runs,
    estimated_labor_cost,
    COALESCE(maintenance_costs, (0)::numeric) AS maintenance_costs,
    equipment_depreciation,
    (((estimated_labor_cost)::numeric + COALESCE(maintenance_costs, (0)::numeric)) + (equipment_depreciation)::numeric) AS total_costs,
    ((((estimated_labor_cost)::numeric + COALESCE(maintenance_costs, (0)::numeric)) + (equipment_depreciation)::numeric) / (NULLIF(total_output, 0))::numeric) AS cost_per_unit,
    avg_production_hours
   FROM cost_breakdown
  WHERE (month IS NOT NULL);
