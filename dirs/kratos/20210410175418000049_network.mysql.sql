UPDATE selfservice_recovery_flows SET nid = (SELECT id FROM networks LIMIT 1);
