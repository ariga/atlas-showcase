-- atlas:import ../public.sql
-- atlas:import gantt_tasks.sql

-- create "gantt_task_dependencies" table
CREATE TABLE "public"."gantt_task_dependencies" (
  "id" serial NOT NULL,
  "predecessor_id" integer NOT NULL,
  "successor_id" integer NOT NULL,
  "dependency_type" character varying(10) NOT NULL,
  "lag_days" integer NULL DEFAULT 0,
  PRIMARY KEY ("id"),
  CONSTRAINT "gantt_task_dependencies_predecessor_id_successor_id_key" UNIQUE ("predecessor_id", "successor_id"),
  CONSTRAINT "gantt_task_dependencies_predecessor_id_fkey" FOREIGN KEY ("predecessor_id") REFERENCES "public"."gantt_tasks" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "gantt_task_dependencies_successor_id_fkey" FOREIGN KEY ("successor_id") REFERENCES "public"."gantt_tasks" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "gantt_task_dependencies_dependency_type_check" CHECK ((dependency_type)::text = ANY (ARRAY[('FS'::character varying)::text, ('FF'::character varying)::text, ('SS'::character varying)::text, ('SF'::character varying)::text]))
);
