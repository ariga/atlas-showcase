-- atlas:import ../functions/create_document_version.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/knowledge_documents.sql

-- create trigger "trg_create_document_version"
CREATE TRIGGER "trg_create_document_version" BEFORE UPDATE ON "public"."knowledge_documents" FOR EACH ROW WHEN (old.content IS DISTINCT FROM new.content) EXECUTE FUNCTION "public"."create_document_version"();
