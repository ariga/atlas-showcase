-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/equipment.sql
-- atlas:import ../tables/maintenance_work_orders.sql
-- atlas:import ../tables/production_lines.sql
-- atlas:import ../tables/production_runs.sql
-- atlas:import ../../public/tables/projects.sql
-- atlas:import ../../public/types/enum_project_status_type.sql

-- create "project_manufacturing_status" view
CREATE VIEW "manufacturing"."project_manufacturing_status" (
  "project_id",
  "project_name",
  "project_status",
  "assigned_production_lines",
  "total_production_runs",
  "total_planned_quantity",
  "total_actual_quantity",
  "passed_runs",
  "failed_runs",
  "first_production_start",
  "last_production_end",
  "related_work_orders",
  "total_maintenance_costs",
  "production_line_names"
) AS SELECT p.id AS project_id,
    p.name AS project_name,
    p.status AS project_status,
    count(DISTINCT pl.id) AS assigned_production_lines,
    count(DISTINCT pr.id) AS total_production_runs,
    sum(pr.planned_quantity) AS total_planned_quantity,
    sum(pr.actual_quantity) AS total_actual_quantity,
    count(
        CASE
            WHEN pr.quality_status = 'pass'::manufacturing.quality_status THEN 1
            ELSE NULL::integer
        END) AS passed_runs,
    count(
        CASE
            WHEN pr.quality_status = ANY (ARRAY['fail'::manufacturing.quality_status, 'rework'::manufacturing.quality_status]) THEN 1
            ELSE NULL::integer
        END) AS failed_runs,
    min(pr.start_time) AS first_production_start,
    max(pr.end_time) AS last_production_end,
    count(DISTINCT wo.id) AS related_work_orders,
    sum(wo.actual_cost) AS total_maintenance_costs,
    string_agg(DISTINCT pl.name::text, ', '::text) AS production_line_names
   FROM public.projects p
     LEFT JOIN manufacturing.production_lines pl ON p.id = pl.project_id
     LEFT JOIN manufacturing.production_runs pr ON p.id = pr.project_id
     LEFT JOIN manufacturing.equipment e ON pl.id = e.production_line_id
     LEFT JOIN manufacturing.maintenance_work_orders wo ON e.id = wo.equipment_id AND wo.created_at >= p.created_at
  GROUP BY p.id, p.name, p.status;
