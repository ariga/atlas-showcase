UPDATE sessions SET nid = (SELECT id FROM networks LIMIT 1);
