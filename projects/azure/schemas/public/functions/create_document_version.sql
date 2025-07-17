-- atlas:import ../public.sql
-- atlas:import ../tables/knowledge_document_versions.sql

-- create "create_document_version" function
CREATE FUNCTION "public"."create_document_version" () RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
    v_version_number INTEGER;
BEGIN
    IF OLD.content != NEW.content THEN
        SELECT COALESCE(MAX(version_number), 0) + 1 INTO v_version_number
        FROM knowledge_document_versions
        WHERE document_id = NEW.id;
        
        INSERT INTO knowledge_document_versions (
            document_id,
            version_number,
            content,
            author_id
        ) VALUES (
            NEW.id,
            v_version_number,
            OLD.content,
            NEW.author_id
        );
    END IF;
    RETURN NEW;
END;
$$;
