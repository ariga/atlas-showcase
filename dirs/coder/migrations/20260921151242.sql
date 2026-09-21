-- Modify "api_keys" table
ALTER TABLE "api_keys" ADD CONSTRAINT "api_keys_token_name_max_len_128" CHECK (length(token_name) <= 128);
