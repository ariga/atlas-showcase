-- atlas:import ../public.sql
-- atlas:import users.sql

-- create "resource_calendars" table
CREATE TABLE "public"."resource_calendars" (
  "id" serial NOT NULL,
  "user_id" integer NOT NULL,
  "date" date NOT NULL,
  "is_working_day" boolean NULL DEFAULT true,
  "working_hours" numeric(4,2) NULL DEFAULT 8,
  "notes" text NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "resource_calendars_user_id_date_key" UNIQUE ("user_id", "date"),
  CONSTRAINT "resource_calendars_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- create index "idx_resource_calendars_user_date" to table: "resource_calendars"
CREATE INDEX "idx_resource_calendars_user_date" ON "public"."resource_calendars" ("user_id", "date");
