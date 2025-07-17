-- atlas:import ../public.sql
-- atlas:import iot_devices.sql
-- atlas:import ../types/enum_sensor_type.sql

-- create "iot_sensor_data" table
CREATE TABLE "public"."iot_sensor_data" (
  "device_id" integer NOT NULL,
  "sensor_type" "public"."sensor_type" NOT NULL,
  "value" numeric NOT NULL,
  "unit" character varying(20) NOT NULL,
  "timestamp" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "quality_score" numeric(3,2) NULL,
  "metadata" jsonb NULL,
  PRIMARY KEY ("device_id", "sensor_type", "timestamp"),
  CONSTRAINT "iot_sensor_data_device_id_fkey" FOREIGN KEY ("device_id") REFERENCES "public"."iot_devices" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "iot_sensor_data_quality_score_check" CHECK ((quality_score >= (0)::numeric) AND (quality_score <= (1)::numeric))
) PARTITION BY RANGE ("timestamp");
-- create index "idx_iot_sensor_data_device_time" to table: "iot_sensor_data"
CREATE INDEX "idx_iot_sensor_data_device_time" ON "public"."iot_sensor_data" ("device_id", "timestamp" DESC);
