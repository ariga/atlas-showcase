-- atlas:import ../manufacturing.sql
-- atlas:import production_lines.sql
-- atlas:import ../types/enum_equipment_status.sql

-- create "equipment" table
CREATE TABLE "manufacturing"."equipment" (
  "id" serial NOT NULL,
  "production_line_id" integer NOT NULL,
  "name" character varying(100) NOT NULL,
  "equipment_type" character varying(50) NOT NULL,
  "model" character varying(100) NULL,
  "serial_number" character varying(100) NOT NULL,
  "status" "manufacturing"."equipment_status" NOT NULL DEFAULT 'available',
  "installed_date" date NULL,
  "last_maintenance" timestamptz NULL,
  "next_maintenance" timestamptz NULL,
  "specifications" jsonb NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "equipment_serial_number_key" UNIQUE ("serial_number"),
  CONSTRAINT "equipment_production_line_id_fkey" FOREIGN KEY ("production_line_id") REFERENCES "manufacturing"."production_lines" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
