-- Modify "api_keys" table
ALTER TABLE "api_keys" ADD CONSTRAINT "api_keys_token_name_not_empty" CHECK (length(btrim(token_name)) > 0), ALTER COLUMN "token_name" DROP DEFAULT;
