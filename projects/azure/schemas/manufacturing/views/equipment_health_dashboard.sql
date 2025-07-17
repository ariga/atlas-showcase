-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/equipment.sql
-- atlas:import ../tables/maintenance_work_orders.sql
-- atlas:import ../tables/production_lines.sql
-- atlas:import ../types/enum_equipment_status.sql

-- create "equipment_health_dashboard" view
CREATE MATERIALIZED VIEW "manufacturing"."equipment_health_dashboard" (
  "equipment_id",
  "equipment_name",
  "equipment_type",
  "status",
  "production_line_name",
  "maintenance_status",
  "total_work_orders",
  "open_work_orders",
  "avg_maintenance_hours",
  "total_maintenance_cost",
  "days_since_maintenance"
) AS SELECT e.id AS equipment_id,
    e.name AS equipment_name,
    e.equipment_type,
    e.status,
    pl.name AS production_line_name,
        CASE
            WHEN (e.next_maintenance <= CURRENT_DATE) THEN 'overdue'::text
            WHEN (e.next_maintenance <= (CURRENT_DATE + '7 days'::interval)) THEN 'due_soon'::text
            ELSE 'ok'::text
        END AS maintenance_status,
    count(wo.id) AS total_work_orders,
    count(
        CASE
            WHEN (wo.status = ANY (ARRAY['planned'::manufacturing.work_order_status, 'scheduled'::manufacturing.work_order_status, 'in_progress'::manufacturing.work_order_status])) THEN 1
            ELSE NULL::integer
        END) AS open_work_orders,
    avg(wo.actual_hours) AS avg_maintenance_hours,
    sum(wo.actual_cost) AS total_maintenance_cost,
    EXTRACT(days FROM ((CURRENT_DATE)::timestamp with time zone - e.last_maintenance)) AS days_since_maintenance
   FROM ((manufacturing.equipment e
     JOIN manufacturing.production_lines pl ON ((e.production_line_id = pl.id)))
     LEFT JOIN manufacturing.maintenance_work_orders wo ON (((e.id = wo.equipment_id) AND (wo.created_at >= (CURRENT_DATE - '6 mons'::interval)))))
  GROUP BY e.id, e.name, e.equipment_type, e.status, pl.name, e.next_maintenance, e.last_maintenance;
