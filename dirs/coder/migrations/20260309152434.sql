-- Modify "api_keys" table
ALTER TABLE "api_keys" ADD CONSTRAINT "api_keys_token_name_no_surrounding_whitespace" CHECK (token_name = btrim(token_name));
