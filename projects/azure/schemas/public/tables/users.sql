-- atlas:import ../public.sql
-- atlas:import ../types/enum_user_status_type.sql

-- create "users" table
CREATE TABLE "public"."users" (
  "id" serial NOT NULL,
  "email" character varying(255) NOT NULL,
  "first_name" character varying(100) NOT NULL,
  "last_name" character varying(100) NOT NULL,
  "phone" character varying(20) NULL,
  "hire_date" date NOT NULL DEFAULT CURRENT_DATE,
  "status" "public"."user_status_type" NOT NULL DEFAULT 'active',
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "users_email_valid" CHECK ((email)::text ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text),
  CONSTRAINT "users_hire_date_reasonable" CHECK ((hire_date >= '1990-01-01'::date) AND (hire_date <= (CURRENT_DATE + '1 year'::interval))),
  CONSTRAINT "users_name_not_empty" CHECK ((length(TRIM(BOTH FROM first_name)) > 0) AND (length(TRIM(BOTH FROM last_name)) > 0))
);
-- create index "users_email_unique" to table: "users"
CREATE UNIQUE INDEX "users_email_unique" ON "public"."users" ("email");
-- create index "users_hire_date_idx" to table: "users"
CREATE INDEX "users_hire_date_idx" ON "public"."users" ("hire_date");
-- create index "users_status_idx" to table: "users"
CREATE INDEX "users_status_idx" ON "public"."users" ("status");
