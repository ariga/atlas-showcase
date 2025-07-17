-- atlas:import ../manufacturing.sql
-- atlas:import equipment.sql
-- atlas:import ../types/enum_maintenance_type.sql
-- atlas:import ../types/enum_work_order_status.sql
-- atlas:import ../../public/tables/users.sql
-- atlas:import ../../public/types/enum_priority_level.sql

-- create "maintenance_work_orders" table
CREATE TABLE "manufacturing"."maintenance_work_orders" (
  "id" serial NOT NULL,
  "work_order_number" character varying(50) NOT NULL,
  "equipment_id" integer NOT NULL,
  "maintenance_type" "manufacturing"."maintenance_type" NOT NULL,
  "status" "manufacturing"."work_order_status" NOT NULL DEFAULT 'planned',
  "priority_level" "public"."priority_level" NOT NULL DEFAULT 'medium',
  "title" character varying(200) NOT NULL,
  "description" text NULL,
  "assigned_technician_id" integer NULL,
  "requested_by_id" integer NULL,
  "estimated_hours" numeric(6,2) NULL,
  "actual_hours" numeric(6,2) NULL,
  "estimated_cost" numeric(12,2) NULL DEFAULT 0,
  "actual_cost" numeric(12,2) NULL DEFAULT 0,
  "scheduled_start" timestamptz NULL,
  "scheduled_end" timestamptz NULL,
  "actual_start" timestamptz NULL,
  "actual_end" timestamptz NULL,
  "completion_notes" text NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "maintenance_work_orders_work_order_number_key" UNIQUE ("work_order_number"),
  CONSTRAINT "maintenance_work_orders_assigned_technician_id_fkey" FOREIGN KEY ("assigned_technician_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "maintenance_work_orders_equipment_id_fkey" FOREIGN KEY ("equipment_id") REFERENCES "manufacturing"."equipment" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "maintenance_work_orders_requested_by_id_fkey" FOREIGN KEY ("requested_by_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "maintenance_work_orders_actual_hours_check" CHECK (actual_hours >= (0)::numeric),
  CONSTRAINT "maintenance_work_orders_estimated_hours_check" CHECK (estimated_hours > (0)::numeric),
  CONSTRAINT "work_orders_time_logic" CHECK (((scheduled_end IS NULL) OR (scheduled_start IS NULL) OR (scheduled_end > scheduled_start)) AND ((actual_end IS NULL) OR (actual_start IS NULL) OR (actual_end > actual_start)))
);
