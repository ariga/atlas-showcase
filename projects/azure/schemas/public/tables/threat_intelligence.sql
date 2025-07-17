-- atlas:import ../public.sql
-- atlas:import ../types/enum_event_severity.sql
-- atlas:import ../types/enum_threat_category.sql

-- create "threat_intelligence" table
CREATE TABLE "public"."threat_intelligence" (
  "id" serial NOT NULL,
  "threat_id" character varying(100) NOT NULL,
  "category" "public"."threat_category" NOT NULL,
  "severity" "public"."event_severity" NOT NULL,
  "description" text NOT NULL,
  "indicators" jsonb NOT NULL,
  "first_seen" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "last_seen" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "is_active" boolean NULL DEFAULT true,
  "metadata" jsonb NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "threat_intelligence_threat_id_key" UNIQUE ("threat_id")
);
-- create index "idx_threat_intelligence_active" to table: "threat_intelligence"
CREATE INDEX "idx_threat_intelligence_active" ON "public"."threat_intelligence" ("is_active", "severity");
