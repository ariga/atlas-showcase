UPDATE courier_messages SET nid = (SELECT id FROM networks LIMIT 1);
