-- Create index "idx_users_last_seen_at_desc" to table: "users"
CREATE INDEX "idx_users_last_seen_at_desc" ON "users" ("last_seen_at" DESC) WHERE (deleted = false);
