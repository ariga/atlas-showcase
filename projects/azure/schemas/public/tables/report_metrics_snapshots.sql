-- atlas:import ../public.sql

-- create "report_metrics_snapshots" table
CREATE TABLE "public"."report_metrics_snapshots" (
  "id" serial NOT NULL,
  "metric_name" character varying(100) NOT NULL,
  "metric_value" jsonb NOT NULL,
  "dimensions" jsonb NULL DEFAULT '{}',
  "snapshot_date" date NOT NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "report_metrics_snapshots_metric_name_dimensions_snapshot_da_key" UNIQUE ("metric_name", "dimensions", "snapshot_date")
);
-- create index "idx_report_metrics_snapshots_metric" to table: "report_metrics_snapshots"
CREATE INDEX "idx_report_metrics_snapshots_metric" ON "public"."report_metrics_snapshots" ("metric_name", "snapshot_date" DESC);
