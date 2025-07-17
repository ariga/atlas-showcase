-- atlas:import ../manufacturing.sql
-- atlas:import equipment.sql
-- atlas:import ../types/enum_equipment_status.sql
-- atlas:import ../../public/tables/users.sql

-- create "equipment_status_log" table
CREATE TABLE "manufacturing"."equipment_status_log" (
  "id" serial NOT NULL,
  "equipment_id" integer NOT NULL,
  "old_status" "manufacturing"."equipment_status" NULL,
  "new_status" "manufacturing"."equipment_status" NOT NULL,
  "change_timestamp" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "change_reason" text NULL,
  "changed_by_user_id" integer NULL,
  "metadata" jsonb NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "equipment_status_log_changed_by_user_id_fkey" FOREIGN KEY ("changed_by_user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "equipment_status_log_equipment_id_fkey" FOREIGN KEY ("equipment_id") REFERENCES "manufacturing"."equipment" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- create index "idx_equipment_status_log_equipment" to table: "equipment_status_log"
CREATE INDEX "idx_equipment_status_log_equipment" ON "manufacturing"."equipment_status_log" ("equipment_id");
-- create index "idx_equipment_status_log_timestamp" to table: "equipment_status_log"
CREATE INDEX "idx_equipment_status_log_timestamp" ON "manufacturing"."equipment_status_log" ("change_timestamp" DESC);
