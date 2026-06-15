-- Modify "organizations" table
ALTER TABLE "organizations" ADD COLUMN "deleted" boolean NOT NULL DEFAULT false;
-- Create index "idx_organizations_lower_name_active" to table: "organizations"
CREATE UNIQUE INDEX "idx_organizations_lower_name_active" ON "organizations" ((lower(name))) WHERE (deleted = false);
