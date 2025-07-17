-- atlas:import ../public.sql
-- atlas:import knowledge_categories.sql
-- atlas:import users.sql
-- atlas:import ../types/enum_doc_format.sql
-- atlas:import ../types/enum_doc_status.sql

-- create "knowledge_documents" table
CREATE TABLE "public"."knowledge_documents" (
  "id" serial NOT NULL,
  "title" character varying(200) NOT NULL,
  "slug" character varying(200) NOT NULL,
  "category_id" integer NULL,
  "format" "public"."doc_format" NOT NULL DEFAULT 'markdown',
  "status" "public"."doc_status" NOT NULL DEFAULT 'draft',
  "author_id" integer NOT NULL,
  "content" text NOT NULL,
  "summary" text NULL,
  "tags" text[] NULL DEFAULT '{}',
  "search_vector" tsvector NULL,
  "view_count" integer NULL DEFAULT 0,
  "created_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
  "published_at" timestamptz NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "knowledge_documents_slug_key" UNIQUE ("slug"),
  CONSTRAINT "knowledge_documents_author_id_fkey" FOREIGN KEY ("author_id") REFERENCES "public"."users" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "knowledge_documents_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."knowledge_categories" ("id") ON UPDATE NO ACTION ON DELETE NO ACTION
);
-- create index "idx_knowledge_documents_author" to table: "knowledge_documents"
CREATE INDEX "idx_knowledge_documents_author" ON "public"."knowledge_documents" ("author_id");
-- create index "idx_knowledge_documents_category" to table: "knowledge_documents"
CREATE INDEX "idx_knowledge_documents_category" ON "public"."knowledge_documents" ("category_id");
-- create index "idx_knowledge_documents_search" to table: "knowledge_documents"
CREATE INDEX "idx_knowledge_documents_search" ON "public"."knowledge_documents" USING gin ("search_vector");
-- create index "idx_knowledge_documents_status" to table: "knowledge_documents"
CREATE INDEX "idx_knowledge_documents_status" ON "public"."knowledge_documents" ("status");
-- create index "idx_knowledge_documents_tags" to table: "knowledge_documents"
CREATE INDEX "idx_knowledge_documents_tags" ON "public"."knowledge_documents" USING gin ("tags");
