-- atlas:import ../public.sql
-- atlas:import ../types/enum_sensor_type.sql

-- create "iot_device_models" table
CREATE TABLE "public"."iot_device_models" (
  "id" serial NOT NULL,
  "name" character varying(100) NOT NULL,
  "manufacturer" character varying(100) NOT NULL,
  "model_number" character varying(50) NOT NULL,
  "firmware_version" character varying(20) NULL,
  "supported_sensors" "public"."sensor_type"[] NOT NULL,
  "specifications" jsonb NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "iot_device_models_manufacturer_model_number_key" UNIQUE ("manufacturer", "model_number")
);
