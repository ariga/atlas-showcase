UPDATE selfservice_registration_flows SET nid = (SELECT id FROM networks LIMIT 1);
