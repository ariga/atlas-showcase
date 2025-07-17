-- atlas:import ../public.sql
-- atlas:import tasks.sql
-- atlas:import users.sql

-- create "task_work_logs" table
CREATE TABLE "public"."task_work_logs" (
  "id" serial NOT NULL,
  "task_id" integer NOT NULL,
  "user_id" integer NOT NULL,
  "hours_worked" numeric(5,2) NOT NULL,
  "work_date" date NOT NULL,
  "description" text NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "task_work_logs_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "public"."tasks" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "task_work_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "task_work_logs_hours_worked_check" CHECK (hours_worked > (0)::numeric)
);
-- create index "idx_task_work_logs_date" to table: "task_work_logs"
CREATE INDEX "idx_task_work_logs_date" ON "public"."task_work_logs" ("work_date" DESC);
-- create index "idx_task_work_logs_task" to table: "task_work_logs"
CREATE INDEX "idx_task_work_logs_task" ON "public"."task_work_logs" ("task_id");
-- create index "idx_task_work_logs_user" to table: "task_work_logs"
CREATE INDEX "idx_task_work_logs_user" ON "public"."task_work_logs" ("user_id");
