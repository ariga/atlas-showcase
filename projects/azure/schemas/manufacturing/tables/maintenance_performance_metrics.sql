-- atlas:import ../manufacturing.sql
-- atlas:import equipment.sql
-- atlas:import maintenance_work_orders.sql
-- atlas:import ../types/enum_maintenance_type.sql

-- create "maintenance_performance_metrics" table
CREATE TABLE "manufacturing"."maintenance_performance_metrics" (
  "id" serial NOT NULL,
  "work_order_id" integer NOT NULL,
  "equipment_id" integer NOT NULL,
  "maintenance_type" "manufacturing"."maintenance_type" NOT NULL,
  "estimated_hours" numeric(6,2) NULL,
  "actual_hours" numeric(6,2) NULL,
  "hours_variance_pct" numeric(6,2) NULL,
  "estimated_cost" numeric(12,2) NULL,
  "actual_cost" numeric(12,2) NULL,
  "cost_variance_pct" numeric(6,2) NULL,
  "completion_date" timestamptz NOT NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "maintenance_performance_metrics_equipment_id_fkey" FOREIGN KEY ("equipment_id") REFERENCES "manufacturing"."equipment" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "maintenance_performance_metrics_work_order_id_fkey" FOREIGN KEY ("work_order_id") REFERENCES "manufacturing"."maintenance_work_orders" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- create index "idx_maintenance_metrics_date" to table: "maintenance_performance_metrics"
CREATE INDEX "idx_maintenance_metrics_date" ON "manufacturing"."maintenance_performance_metrics" ("completion_date" DESC);
-- create index "idx_maintenance_metrics_equipment" to table: "maintenance_performance_metrics"
CREATE INDEX "idx_maintenance_metrics_equipment" ON "manufacturing"."maintenance_performance_metrics" ("equipment_id");
-- create index "idx_maintenance_metrics_type" to table: "maintenance_performance_metrics"
CREATE INDEX "idx_maintenance_metrics_type" ON "manufacturing"."maintenance_performance_metrics" ("maintenance_type");
