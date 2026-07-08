-- Modify "api_keys" table
ALTER TABLE "api_keys" ADD CONSTRAINT "api_keys_hashed_secret_not_empty" CHECK (octet_length(hashed_secret) > 0);
