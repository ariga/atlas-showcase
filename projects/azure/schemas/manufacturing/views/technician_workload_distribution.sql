-- atlas:import ../manufacturing.sql
-- atlas:import ../tables/maintenance_work_orders.sql
-- atlas:import ../../public/tables/users.sql

-- create "technician_workload_distribution" view
CREATE VIEW "manufacturing"."technician_workload_distribution" (
  "technician_id",
  "technician_name",
  "technician_email",
  "total_assigned_orders",
  "pending_orders",
  "active_orders",
  "completed_orders",
  "total_estimated_hours",
  "total_actual_hours",
  "avg_time_variance",
  "remaining_workload_hours",
  "high_priority_orders",
  "maintenance_specialties"
) AS SELECT u.id AS technician_id,
    (u.first_name::text || ' '::text) || u.last_name::text AS technician_name,
    u.email AS technician_email,
    count(*) AS total_assigned_orders,
    count(
        CASE
            WHEN wo.status = ANY (ARRAY['planned'::manufacturing.work_order_status, 'scheduled'::manufacturing.work_order_status]) THEN 1
            ELSE NULL::integer
        END) AS pending_orders,
    count(
        CASE
            WHEN wo.status = 'in_progress'::manufacturing.work_order_status THEN 1
            ELSE NULL::integer
        END) AS active_orders,
    count(
        CASE
            WHEN wo.status = 'completed'::manufacturing.work_order_status THEN 1
            ELSE NULL::integer
        END) AS completed_orders,
    sum(wo.estimated_hours) AS total_estimated_hours,
    sum(wo.actual_hours) AS total_actual_hours,
    avg(wo.actual_hours / NULLIF(wo.estimated_hours, 0::numeric)) AS avg_time_variance,
    sum(
        CASE
            WHEN wo.status = ANY (ARRAY['planned'::manufacturing.work_order_status, 'scheduled'::manufacturing.work_order_status, 'in_progress'::manufacturing.work_order_status]) THEN wo.estimated_hours
            ELSE 0::numeric
        END) AS remaining_workload_hours,
    count(
        CASE
            WHEN wo.priority_level = 'high'::public.priority_level THEN 1
            ELSE NULL::integer
        END) AS high_priority_orders,
    string_agg(DISTINCT wo.maintenance_type::text, ', '::text) AS maintenance_specialties
   FROM public.users u
     JOIN manufacturing.maintenance_work_orders wo ON u.id = wo.assigned_technician_id
  WHERE wo.created_at >= (CURRENT_DATE - '6 mons'::interval)
  GROUP BY u.id, u.first_name, u.last_name, u.email;
