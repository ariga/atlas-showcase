script "loop" "purge_inactive" {
  iterator "keyset" {
    cursor {
      id = int
    }
    init {
      sql = "SELECT id FROM users WHERE active = 0 ORDER BY id LIMIT 500"
    }
    next {
      sql  = "SELECT id FROM users WHERE active = 0 AND id > ? ORDER BY id LIMIT 500"
      args = [cursor.id]
    }
  }
  do {
    exec {
      sql  = "DELETE FROM users WHERE id IN (SELECT value FROM json_each(?))"
      args = [jsonencode(iterator.keyset.batch[*].id)]
    }
  }
}
