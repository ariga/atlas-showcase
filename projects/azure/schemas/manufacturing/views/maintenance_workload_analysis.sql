-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/maintenance_work_orders.sql
-- atlas:import ../types/enum_maintenance_type.sql
-- atlas:import ../../public/tables/users.sql
-- atlas:import ../../public/types/enum_priority_level.sql

-- create "maintenance_workload_analysis" view
CREATE MATERIALIZED VIEW "manufacturing"."maintenance_workload_analysis" (
  "week_start",
  "maintenance_type",
  "priority_level",
  "scheduled_work_orders",
  "estimated_hours",
  "actual_hours",
  "hours_variance_ratio",
  "completed_orders",
  "overdue_completions",
  "assigned_technicians"
) AS SELECT date_trunc('week'::text, wo.scheduled_start) AS week_start,
    wo.maintenance_type,
    wo.priority_level,
    count(*) AS scheduled_work_orders,
    sum(wo.estimated_hours) AS estimated_hours,
    sum(wo.actual_hours) AS actual_hours,
    avg((wo.actual_hours / NULLIF(wo.estimated_hours, (0)::numeric))) AS hours_variance_ratio,
    count(
        CASE
            WHEN (wo.status = 'completed'::manufacturing.work_order_status) THEN 1
            ELSE NULL::integer
        END) AS completed_orders,
    count(
        CASE
            WHEN (wo.actual_end > wo.scheduled_end) THEN 1
            ELSE NULL::integer
        END) AS overdue_completions,
    string_agg(DISTINCT (((u.first_name)::text || ' '::text) || (u.last_name)::text), ', '::text) AS assigned_technicians
   FROM (manufacturing.maintenance_work_orders wo
     LEFT JOIN public.users u ON ((wo.assigned_technician_id = u.id)))
  WHERE ((wo.scheduled_start >= (CURRENT_DATE - '84 days'::interval)) AND (wo.scheduled_start <= (CURRENT_DATE + '28 days'::interval)))
  GROUP BY (date_trunc('week'::text, wo.scheduled_start)), wo.maintenance_type, wo.priority_level;
