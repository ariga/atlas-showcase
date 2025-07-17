-- atlas:import ../public.sql
-- atlas:import users.sql

-- create "ml_datasets" table
CREATE TABLE "public"."ml_datasets" (
  "id" serial NOT NULL,
  "name" character varying(255) NOT NULL,
  "description" text NULL,
  "dataset_type" character varying(50) NOT NULL,
  "source_uri" text NOT NULL,
  "format" character varying(50) NOT NULL,
  "size_gb" numeric(10,3) NULL,
  "row_count" bigint NULL,
  "column_count" integer NULL,
  "schema_definition" jsonb NULL,
  "statistics" jsonb NULL,
  "quality_metrics" jsonb NULL,
  "tags" text[] NULL DEFAULT '{}',
  "is_active" boolean NOT NULL DEFAULT true,
  "created_by" integer NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "ml_datasets_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "ml_datasets_counts_positive" CHECK (((row_count IS NULL) OR (row_count > 0)) AND ((column_count IS NULL) OR (column_count > 0))),
  CONSTRAINT "ml_datasets_size_positive" CHECK ((size_gb IS NULL) OR (size_gb > (0)::numeric))
);
-- create index "ml_datasets_active_idx" to table: "ml_datasets"
CREATE INDEX "ml_datasets_active_idx" ON "public"."ml_datasets" ("is_active");
-- create index "ml_datasets_name_idx" to table: "ml_datasets"
CREATE INDEX "ml_datasets_name_idx" ON "public"."ml_datasets" ("name");
-- create index "ml_datasets_tags_gin" to table: "ml_datasets"
CREATE INDEX "ml_datasets_tags_gin" ON "public"."ml_datasets" USING gin ("tags");
-- create index "ml_datasets_type_idx" to table: "ml_datasets"
CREATE INDEX "ml_datasets_type_idx" ON "public"."ml_datasets" ("dataset_type");
