UPDATE selfservice_errors SET nid = (SELECT id FROM networks LIMIT 1);
