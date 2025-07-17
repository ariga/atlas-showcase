-- atlas:import ../public.sql
-- atlas:import iot_devices.sql
-- atlas:import users.sql
-- atlas:import ../types/enum_alert_severity.sql
-- atlas:import ../types/enum_alert_status.sql
-- atlas:import ../types/enum_sensor_type.sql

-- create "iot_device_alerts" table
CREATE TABLE "public"."iot_device_alerts" (
  "id" serial NOT NULL,
  "device_id" integer NOT NULL,
  "sensor_type" "public"."sensor_type" NULL,
  "severity" "public"."alert_severity" NOT NULL,
  "status" "public"."alert_status" NOT NULL DEFAULT 'open',
  "condition" character varying(200) NOT NULL,
  "threshold_value" numeric NULL,
  "actual_value" numeric NULL,
  "alert_message" text NOT NULL,
  "triggered_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "acknowledged_at" timestamptz NULL,
  "resolved_at" timestamptz NULL,
  "acknowledged_by" integer NULL,
  "resolution_notes" text NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "iot_device_alerts_acknowledged_by_fkey" FOREIGN KEY ("acknowledged_by") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "iot_device_alerts_device_id_fkey" FOREIGN KEY ("device_id") REFERENCES "public"."iot_devices" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- create index "idx_iot_device_alerts_device" to table: "iot_device_alerts"
CREATE INDEX "idx_iot_device_alerts_device" ON "public"."iot_device_alerts" ("device_id");
-- create index "idx_iot_device_alerts_status" to table: "iot_device_alerts"
CREATE INDEX "idx_iot_device_alerts_status" ON "public"."iot_device_alerts" ("status") WHERE (status = ANY (ARRAY['open'::public.alert_status, 'acknowledged'::public.alert_status]));
