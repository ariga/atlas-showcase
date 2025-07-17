-- atlas:import ../public.sql
-- atlas:import gantt_tasks.sql
-- atlas:import users.sql

-- create "gantt_resource_assignments" table
CREATE TABLE "public"."gantt_resource_assignments" (
  "id" serial NOT NULL,
  "gantt_task_id" integer NOT NULL,
  "user_id" integer NOT NULL,
  "allocation_percentage" numeric(5,2) NOT NULL,
  "start_date" date NOT NULL,
  "end_date" date NOT NULL,
  "hello_world" text NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "gantt_resource_assignments_gantt_task_id_user_id_key" UNIQUE ("gantt_task_id", "user_id"),
  CONSTRAINT "gantt_resource_assignments_gantt_task_id_fkey" FOREIGN KEY ("gantt_task_id") REFERENCES "public"."gantt_tasks" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "gantt_resource_assignments_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "gantt_resource_assignments_allocation_percentage_check" CHECK ((allocation_percentage > (0)::numeric) AND (allocation_percentage <= (100)::numeric))
);
-- create index "idx_gantt_resource_assignments_user" to table: "gantt_resource_assignments"
CREATE INDEX "idx_gantt_resource_assignments_user" ON "public"."gantt_resource_assignments" ("user_id");
