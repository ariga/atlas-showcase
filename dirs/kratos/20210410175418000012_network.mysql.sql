UPDATE selfservice_settings_flows SET nid = (SELECT id FROM networks LIMIT 1);
