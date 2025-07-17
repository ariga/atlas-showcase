-- atlas:import ../public.sql

-- create "knowledge_categories" table
CREATE TABLE "public"."knowledge_categories" (
  "id" serial NOT NULL,
  "name" character varying(100) NOT NULL,
  "slug" character varying(100) NOT NULL,
  "parent_id" integer NULL,
  "description" text NULL,
  "icon" character varying(50) NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "knowledge_categories_slug_key" UNIQUE ("slug"),
  CONSTRAINT "knowledge_categories_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "public"."knowledge_categories" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
