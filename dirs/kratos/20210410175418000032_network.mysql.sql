UPDATE identities SET nid = (SELECT id FROM networks LIMIT 1);
