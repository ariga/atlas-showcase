-- atlas:import ../public.sql
-- atlas:import knowledge_documents.sql
-- atlas:import users.sql

-- create "knowledge_document_versions" table
CREATE TABLE "public"."knowledge_document_versions" (
  "id" serial NOT NULL,
  "document_id" integer NOT NULL,
  "version_number" integer NOT NULL,
  "content" text NOT NULL,
  "change_summary" text NULL,
  "author_id" integer NOT NULL,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("id"),
  CONSTRAINT "knowledge_document_versions_document_id_version_number_key" UNIQUE ("document_id", "version_number"),
  CONSTRAINT "knowledge_document_versions_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "knowledge_document_versions_document_id_fkey" FOREIGN KEY ("document_id") REFERENCES "public"."knowledge_documents" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
