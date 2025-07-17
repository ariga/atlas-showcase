-- atlas:import ../public.sql
-- atlas:import ../types/enum_sensor_type.sql

-- create "iot_sensor_types" table
CREATE TABLE "public"."iot_sensor_types" (
  "id" serial NOT NULL,
  "sensor_type" "public"."sensor_type" NOT NULL,
  "unit" character varying(20) NOT NULL,
  "min_value" numeric NULL,
  "max_value" numeric NULL,
  "precision" integer NULL DEFAULT 2,
  "alert_thresholds" jsonb NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id")
);
