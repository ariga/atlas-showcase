UPDATE selfservice_login_flows SET nid = (SELECT id FROM networks LIMIT 1);
