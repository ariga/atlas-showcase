UPDATE continuity_containers SET nid = (SELECT id FROM networks LIMIT 1);
