-- Modify "site_configs" table
ALTER TABLE "site_configs" DROP CONSTRAINT "site_configs_key_key", ADD PRIMARY KEY ("key");
