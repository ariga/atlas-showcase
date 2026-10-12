-- Create index "idx_api_keys_user_id_expires_at" to table: "api_keys"
CREATE INDEX "idx_api_keys_user_id_expires_at" ON "api_keys" ("user_id", "expires_at");
