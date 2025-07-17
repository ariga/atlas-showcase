-- atlas:import ../public.sql
-- atlas:import ../tables/iot_device_alerts.sql
-- atlas:import ../tables/iot_device_models.sql
-- atlas:import ../tables/iot_devices.sql
-- atlas:import ../types/enum_device_status.sql

-- create "iot_device_health" view
CREATE VIEW "public"."iot_device_health" (
  "id",
  "serial_number",
  "status",
  "last_seen",
  "connectivity_status",
  "active_alerts",
  "model_name",
  "manufacturer"
) AS SELECT d.id,
    d.serial_number,
    d.status,
    d.last_seen,
        CASE
            WHEN d.last_seen IS NULL THEN 'never_seen'::text
            WHEN d.last_seen < (CURRENT_TIMESTAMP - '01:00:00'::interval) THEN 'offline'::text
            WHEN d.last_seen < (CURRENT_TIMESTAMP - '00:10:00'::interval) THEN 'delayed'::text
            ELSE 'online'::text
        END AS connectivity_status,
    count(DISTINCT a.id) FILTER (WHERE a.status = ANY (ARRAY['open'::public.alert_status, 'acknowledged'::public.alert_status])) AS active_alerts,
    dm.name AS model_name,
    dm.manufacturer
   FROM public.iot_devices d
     JOIN public.iot_device_models dm ON d.device_model_id = dm.id
     LEFT JOIN public.iot_device_alerts a ON d.id = a.device_id
  GROUP BY d.id, d.serial_number, d.status, d.last_seen, dm.name, dm.manufacturer;
