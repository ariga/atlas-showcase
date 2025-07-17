-- Modify "gantt_tasks" table
ALTER TABLE "public"."gantt_tasks" ADD COLUMN "updated_at" timestamptz NOT NULL;
