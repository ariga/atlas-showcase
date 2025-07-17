-- atlas:import ../public.sql
-- atlas:import iot_device_models.sql
-- atlas:import ../types/enum_device_status.sql

-- create "iot_devices" table
CREATE TABLE "public"."iot_devices" (
  "id" serial NOT NULL,
  "device_model_id" integer NOT NULL,
  "serial_number" character varying(100) NOT NULL,
  "location" character varying(200) NULL,
  "coordinates" point NULL,
  "status" "public"."device_status" NOT NULL DEFAULT 'active',
  "deployed_at" timestamptz NULL,
  "last_seen" timestamptz NULL,
  "first_seen" timestamptz NOT NULL,
  "metadata" jsonb NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "iot_devices_serial_number_key" UNIQUE ("serial_number"),
  CONSTRAINT "iot_devices_device_model_id_fkey" FOREIGN KEY ("device_model_id") REFERENCES "public"."iot_device_models" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- create index "idx_iot_devices_last_seen" to table: "iot_devices"
CREATE INDEX "idx_iot_devices_last_seen" ON "public"."iot_devices" ("last_seen");
-- create index "idx_iot_devices_status" to table: "iot_devices"
CREATE INDEX "idx_iot_devices_status" ON "public"."iot_devices" ("status");
