-- Create trigger "trigger_update_users"
CREATE TRIGGER "trigger_update_users" AFTER UPDATE OF "deleted" ON "users" FOR EACH ROW WHEN ((new.deleted = true) AND (old.deleted IS DISTINCT FROM new.deleted)) EXECUTE FUNCTION "delete_deleted_user_api_keys"();
