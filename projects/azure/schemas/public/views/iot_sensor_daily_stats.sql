-- atlas:import ../public.sql
-- atlas:import ../tables/iot_sensor_data.sql
-- atlas:import ../types/enum_sensor_type.sql

-- create "iot_sensor_daily_stats" view
CREATE MATERIALIZED VIEW "public"."iot_sensor_daily_stats" (
  "device_id",
  "sensor_type",
  "date",
  "reading_count",
  "avg_value",
  "min_value",
  "max_value",
  "stddev_value",
  "avg_quality"
) AS SELECT device_id,
    sensor_type,
    date("timestamp") AS date,
    count(*) AS reading_count,
    avg(value) AS avg_value,
    min(value) AS min_value,
    max(value) AS max_value,
    stddev(value) AS stddev_value,
    avg(quality_score) AS avg_quality
   FROM public.iot_sensor_data
  WHERE ("timestamp" >= (CURRENT_DATE - '90 days'::interval))
  GROUP BY device_id, sensor_type, (date("timestamp"));
-- create index "idx_iot_sensor_daily_stats" to table: "iot_sensor_daily_stats"
CREATE INDEX "idx_iot_sensor_daily_stats" ON "public"."iot_sensor_daily_stats" ("device_id", "date" DESC);
