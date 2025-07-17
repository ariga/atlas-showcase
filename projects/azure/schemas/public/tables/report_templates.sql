-- atlas:import ../public.sql
-- atlas:import users.sql

-- create "report_templates" table
CREATE TABLE "public"."report_templates" (
  "id" serial NOT NULL,
  "name" character varying(200) NOT NULL,
  "description" text NULL,
  "template_type" character varying(50) NOT NULL,
  "query_template" text NOT NULL,
  "parameters" jsonb NULL DEFAULT '{}',
  "layout" jsonb NULL,
  "created_by" integer NOT NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "report_templates_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
