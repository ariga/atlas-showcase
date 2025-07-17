-- atlas:import ../public.sql
-- atlas:import report_templates.sql
-- atlas:import users.sql

-- create "report_subscriptions" table
CREATE TABLE "public"."report_subscriptions" (
  "id" serial NOT NULL,
  "template_id" integer NOT NULL,
  "user_id" integer NOT NULL,
  "schedule" character varying(50) NOT NULL,
  "parameters" jsonb NULL DEFAULT '{}',
  "last_run" timestamptz NULL,
  "next_run" timestamptz NULL,
  "is_active" boolean NULL DEFAULT true,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "report_subscriptions_template_id_user_id_key" UNIQUE ("template_id", "user_id"),
  CONSTRAINT "report_subscriptions_template_id_fkey" FOREIGN KEY ("template_id") REFERENCES "public"."report_templates" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "report_subscriptions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- create index "idx_report_subscriptions_active" to table: "report_subscriptions"
CREATE INDEX "idx_report_subscriptions_active" ON "public"."report_subscriptions" ("is_active", "next_run");
-- create index "idx_report_subscriptions_user" to table: "report_subscriptions"
CREATE INDEX "idx_report_subscriptions_user" ON "public"."report_subscriptions" ("user_id");
