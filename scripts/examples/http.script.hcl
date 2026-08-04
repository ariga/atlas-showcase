script "loop" "purge_deleted" {
  iterator "keyset" {
    cursor {
      id = int
    }
    init {
      sql = "SELECT id FROM users WHERE deleted = 1 AND purged = 0 ORDER BY id LIMIT 100"
    }
    next {
      sql  = "SELECT id FROM users WHERE deleted = 1 AND purged = 0 AND id > ? ORDER BY id LIMIT 100"
      args = [cursor.id]
    }
  }
  do {
    http "search" {
      url           = "https://search.internal/documents/delete"
      method        = POST
      headers       = { Content-Type = "application/json" }
      body          = jsonencode({ ids = iterator.keyset.batch[*].id })
      expect_status = 200
    }
    // Mark rows purged only after the call succeeds, so a failed
    // batch stays pending and is retried on the next run.
    exec {
      sql  = "UPDATE users SET purged = 1 WHERE id IN (SELECT value FROM json_each(?))"
      args = [jsonencode(iterator.keyset.batch[*].id)]
    }
  }
  policy {
    tx {
      mode = MANUAL
    }
  }
}
