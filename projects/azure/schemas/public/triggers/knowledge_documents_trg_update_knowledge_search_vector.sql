-- atlas:import ../functions/update_knowledge_search_vector.sql
-- atlas:import ../public.sql
-- atlas:import ../tables/knowledge_documents.sql

-- create trigger "trg_update_knowledge_search_vector"
CREATE TRIGGER "trg_update_knowledge_search_vector" BEFORE INSERT OR UPDATE OF "content", "summary", "tags", "title" ON "public"."knowledge_documents" FOR EACH ROW EXECUTE FUNCTION "public"."update_knowledge_search_vector"();
