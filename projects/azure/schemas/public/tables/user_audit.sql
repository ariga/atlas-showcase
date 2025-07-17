-- atlas:import ../public.sql
-- atlas:import users.sql

-- create "user_audit" table
CREATE TABLE "public"."user_audit" (
  "id" serial NOT NULL,
  "user_id" integer NOT NULL,
  "operation" character varying(10) NOT NULL,
  "old_values" jsonb NULL,
  "new_values" jsonb NULL,
  "changed_by" integer NULL,
  "changed_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "user_audit_changed_by_fkey" FOREIGN KEY ("changed_by") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "user_audit_operation_valid" CHECK ((operation)::text = ANY (ARRAY[('INSERT'::character varying)::text, ('UPDATE'::character varying)::text, ('DELETE'::character varying)::text]))
);
-- create index "user_audit_changed_at_idx" to table: "user_audit"
CREATE INDEX "user_audit_changed_at_idx" ON "public"."user_audit" ("changed_at");
-- create index "user_audit_user_id_idx" to table: "user_audit"
CREATE INDEX "user_audit_user_id_idx" ON "public"."user_audit" ("user_id");
