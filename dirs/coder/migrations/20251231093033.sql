-- Modify "groups" table
ALTER TABLE "groups" ADD CONSTRAINT "groups_quota_allowance_non_negative" CHECK (quota_allowance >= 0);
