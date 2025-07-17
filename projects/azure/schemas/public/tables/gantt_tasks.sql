-- atlas:import ../public.sql
-- atlas:import gantt_schedules.sql
-- atlas:import tasks.sql

-- create "gantt_tasks" table
CREATE TABLE "public"."gantt_tasks" (
  "id" serial NOT NULL,
  "schedule_id" integer NOT NULL,
  "task_id" integer NULL,
  "name" character varying(200) NOT NULL,
  "start_date" date NOT NULL,
  "end_date" date NOT NULL,
  "duration" integer NOT NULL,
  "progress" numeric(5,2) NULL DEFAULT 0,
  "is_milestone" boolean NULL DEFAULT false,
  "parent_task_id" integer NULL,
  "position" integer NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "gantt_tasks_parent_task_id_fkey" FOREIGN KEY ("parent_task_id") REFERENCES "public"."gantt_tasks" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "gantt_tasks_schedule_id_fkey" FOREIGN KEY ("schedule_id") REFERENCES "public"."gantt_schedules" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "gantt_tasks_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "public"."tasks" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- create index "idx_gantt_tasks_parent" to table: "gantt_tasks"
CREATE INDEX "idx_gantt_tasks_parent" ON "public"."gantt_tasks" ("parent_task_id");
-- create index "idx_gantt_tasks_schedule" to table: "gantt_tasks"
CREATE INDEX "idx_gantt_tasks_schedule" ON "public"."gantt_tasks" ("schedule_id");
