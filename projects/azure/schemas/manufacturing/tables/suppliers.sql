-- atlas:import ../manufacturing.sql
-- atlas:import ../types/enum_supplier_status.sql
-- atlas:import ../../public/tables/users.sql

-- create "suppliers" table
CREATE TABLE "manufacturing"."suppliers" (
  "id" serial NOT NULL,
  "name" character varying(200) NOT NULL,
  "code" character varying(50) NOT NULL,
  "status" "manufacturing"."supplier_status" NOT NULL DEFAULT 'pending_approval',
  "contact_email" character varying(255) NULL,
  "contact_phone" character varying(50) NULL,
  "address" text NULL,
  "country_code" character varying(3) NULL,
  "tax_id" character varying(50) NULL,
  "payment_terms" integer NULL DEFAULT 30,
  "quality_rating" numeric(3,2) NULL,
  "delivery_rating" numeric(3,2) NULL,
  "cost_rating" numeric(3,2) NULL,
  "risk_score" numeric(5,2) NULL DEFAULT 0,
  "certification_data" jsonb NULL,
  "procurement_manager_id" integer NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "suppliers_code_key" UNIQUE ("code"),
  CONSTRAINT "suppliers_procurement_manager_id_fkey" FOREIGN KEY ("procurement_manager_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "suppliers_cost_rating_check" CHECK ((cost_rating >= (0)::numeric) AND (cost_rating <= (5)::numeric)),
  CONSTRAINT "suppliers_delivery_rating_check" CHECK ((delivery_rating >= (0)::numeric) AND (delivery_rating <= (5)::numeric)),
  CONSTRAINT "suppliers_payment_terms_valid" CHECK ((payment_terms >= 0) AND (payment_terms <= 365)),
  CONSTRAINT "suppliers_quality_rating_check" CHECK ((quality_rating >= (0)::numeric) AND (quality_rating <= (5)::numeric))
);
