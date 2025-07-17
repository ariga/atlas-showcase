-- atlas:import ../public.sql
-- atlas:import users.sql
-- atlas:import ../types/enum_user_role_type.sql

-- create "user_roles" table
CREATE TABLE "public"."user_roles" (
  "id" serial NOT NULL,
  "user_id" integer NOT NULL,
  "role" "public"."user_role_type" NOT NULL,
  "effective_from" date NOT NULL DEFAULT CURRENT_DATE,
  "effective_to" date NULL,
  "assigned_by" integer NULL,
  "assigned_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "notes" text NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "user_roles_assigned_by_fkey" FOREIGN KEY ("assigned_by") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "user_roles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "user_roles_date_order" CHECK ((effective_to IS NULL) OR (effective_to > effective_from)),
  CONSTRAINT "user_roles_effective_from_reasonable" CHECK (effective_from >= '1990-01-01'::date)
);
-- create index "user_roles_effective_dates_idx" to table: "user_roles"
CREATE INDEX "user_roles_effective_dates_idx" ON "public"."user_roles" ("effective_from", "effective_to");
-- create index "user_roles_user_id_idx" to table: "user_roles"
CREATE INDEX "user_roles_user_id_idx" ON "public"."user_roles" ("user_id");
