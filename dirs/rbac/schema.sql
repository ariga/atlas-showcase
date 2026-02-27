-- Add new schema named "public"
CREATE SCHEMA IF NOT EXISTS "public";
-- Set comment to schema: "public"
COMMENT ON SCHEMA "public" IS 'standard public schema';

-- Database-level objects: Users
CREATE USER app_readonly WITH PASSWORD 'readonly_password';
CREATE USER app_readwrite WITH PASSWORD 'readwrite_password';
CREATE USER app_admin WITH PASSWORD 'admin_password';
CREATE USER app_analyst WITH PASSWORD 'analyst_password';
CREATE USER app_auditor WITH PASSWORD 'auditor_password';

-- Database-level objects: Roles
CREATE ROLE readonly_role;
CREATE ROLE readwrite_role;
CREATE ROLE admin_role with CREATEDB;
CREATE ROLE analyst_role with BYPASSRLS;
CREATE ROLE auditor_role;
CREATE ROLE all_attributes with CREATEDB CREATEROLE INHERIT LOGIN REPLICATION BYPASSRLS;

-- Grant role membership
GRANT readonly_role TO app_readonly;
GRANT readwrite_role TO app_readwrite;
GRANT admin_role TO app_admin;
GRANT analyst_role TO app_analyst;
GRANT auditor_role TO app_auditor;

-- Schema-level objects: Tables
-- Create enum type "user_status"
CREATE TYPE "public"."user_status" AS ENUM ('active', 'inactive', 'suspended');

-- Create "users" table
CREATE TABLE "public"."users" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "email" text NOT NULL,
  "username" text NOT NULL,
  "status" "public"."user_status" NOT NULL DEFAULT 'active',
  "created_at" timestamptz NOT NULL DEFAULT now(),
  "updated_at" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY ("id"),
  CONSTRAINT "users_username_unique" UNIQUE ("username"),
  CONSTRAINT "users_email_lowercase_chk" CHECK ("email" = lower("email"))
);

-- Enforce case-insensitive email uniqueness (replaces users_email_unique)
CREATE UNIQUE INDEX "users_email_unique" ON "public"."users" (lower("email"));

-- Create "departments" table
CREATE TABLE "public"."departments" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "name" text NOT NULL,
  "description" text NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY ("id"),
  CONSTRAINT "departments_name_unique" UNIQUE ("name")
);

-- Create "employees" table
CREATE TABLE "public"."employees" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "user_id" uuid NOT NULL,
  "department_id" uuid NOT NULL,
  "salary" numeric(10,2) NOT NULL,
  "hire_date" date NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY ("id"),
  CONSTRAINT "employees_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "employees_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "public"."departments" ("id") ON UPDATE NO ACTION ON DELETE RESTRICT
);

-- Create "projects" table
CREATE TABLE "public"."projects" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "name" text NOT NULL,
  "description" text NULL,
  "budget" numeric(12,2) NULL,
  "start_date" date NOT NULL,
  "end_date" date NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY ("id")
);

-- Create "project_assignments" table
CREATE TABLE "public"."project_assignments" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "employee_id" uuid NOT NULL,
  "project_id" uuid NOT NULL,
  "role" text NOT NULL DEFAULT 'member',
  "assigned_at" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY ("id"),
  CONSTRAINT "project_assignments_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "public"."employees" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "project_assignments_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects" ("id") ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT "project_assignments_unique" UNIQUE ("employee_id", "project_id")
);

-- Create "audit_logs" table
CREATE TABLE "public"."audit_logs" (
  "id" uuid NOT NULL DEFAULT gen_random_uuid(),
  "table_name" text NOT NULL,
  "action" text NOT NULL,
  "user_id" uuid NULL,
  "old_values" jsonb NULL,
  "new_values" jsonb NULL,
  "created_at" timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY ("id")
);

-- Create indexes
CREATE INDEX "idx_employees_user_id" ON "public"."employees" ("user_id");
CREATE INDEX "idx_employees_department_id" ON "public"."employees" ("department_id");
CREATE INDEX "idx_project_assignments_employee_id" ON "public"."project_assignments" ("employee_id");
CREATE INDEX "idx_project_assignments_project_id" ON "public"."project_assignments" ("project_id");
CREATE INDEX "idx_audit_logs_table_name" ON "public"."audit_logs" ("table_name");
CREATE INDEX "idx_audit_logs_created_at" ON "public"."audit_logs" ("created_at");

-- Database-level permissions: Grant schema usage
GRANT USAGE ON SCHEMA "public" TO readonly_role;
GRANT USAGE ON SCHEMA "public" TO readwrite_role;
GRANT USAGE ON SCHEMA "public" TO admin_role;
GRANT USAGE ON SCHEMA "public" TO analyst_role;
REVOKE USAGE ON SCHEMA "public" FROM auditor_role;

-- Database-level permissions: Read-only access
GRANT SELECT ON ALL TABLES IN SCHEMA "public" TO readonly_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA "public" GRANT SELECT ON TABLES TO readonly_role;

-- Database-level permissions: Read-write access
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA "public" TO readwrite_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA "public" GRANT SELECT, INSERT, UPDATE ON TABLES TO readwrite_role;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA "public" TO readwrite_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA "public" GRANT USAGE, SELECT ON SEQUENCES TO readwrite_role;

-- Database-level permissions: Admin access
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA "public" TO admin_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA "public" GRANT ALL PRIVILEGES ON TABLES TO admin_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA "public" TO admin_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA "public" GRANT ALL PRIVILEGES ON SEQUENCES TO admin_role;

-- Database-level permissions: Analyst access (read-only + specific tables)
GRANT SELECT ON ALL TABLES IN SCHEMA "public" TO analyst_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA "public" GRANT SELECT ON TABLES TO analyst_role;
-- Grant additional access to projects and project_assignments for analysis
GRANT SELECT ON TABLE "public"."projects" TO analyst_role;
GRANT SELECT ON TABLE "public"."project_assignments" TO analyst_role;

-- Database-level permissions: Auditor access (read-only on audit logs)
GRANT SELECT ON TABLE "public"."audit_logs" TO auditor_role;
-- Grant read-only on users and employees for audit context
REVOKE SELECT ON TABLE "public"."users" FROM auditor_role;
