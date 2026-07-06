-- Modify "workspaces" table
ALTER TABLE "workspaces" ADD CONSTRAINT "workspaces_autostart_schedule_null_or_trimmed_non_empty" CHECK ((autostart_schedule IS NULL) OR ((autostart_schedule = btrim(autostart_schedule)) AND (length(btrim(autostart_schedule)) > 0)));
