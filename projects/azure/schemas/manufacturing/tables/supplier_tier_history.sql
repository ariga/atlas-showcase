-- atlas:import ../manufacturing.sql
-- atlas:import suppliers.sql
-- atlas:import ../../public/tables/users.sql

-- create "supplier_tier_history" table
CREATE TABLE "manufacturing"."supplier_tier_history" (
  "id" serial NOT NULL,
  "supplier_id" integer NOT NULL,
  "old_tier" character varying(20) NULL,
  "new_tier" character varying(20) NOT NULL,
  "change_date" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "old_quality_rating" numeric(3,2) NULL,
  "new_quality_rating" numeric(3,2) NULL,
  "old_delivery_rating" numeric(3,2) NULL,
  "new_delivery_rating" numeric(3,2) NULL,
  "old_cost_rating" numeric(3,2) NULL,
  "new_cost_rating" numeric(3,2) NULL,
  "change_reason" text NULL,
  "created_by_user_id" integer NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "supplier_tier_history_created_by_user_id_fkey" FOREIGN KEY ("created_by_user_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "supplier_tier_history_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "manufacturing"."suppliers" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- create index "idx_supplier_tier_history_date" to table: "supplier_tier_history"
CREATE INDEX "idx_supplier_tier_history_date" ON "manufacturing"."supplier_tier_history" ("change_date" DESC);
-- create index "idx_supplier_tier_history_supplier" to table: "supplier_tier_history"
CREATE INDEX "idx_supplier_tier_history_supplier" ON "manufacturing"."supplier_tier_history" ("supplier_id");
-- create index "idx_supplier_tier_history_tier" to table: "supplier_tier_history"
CREATE INDEX "idx_supplier_tier_history_tier" ON "manufacturing"."supplier_tier_history" ("new_tier");
