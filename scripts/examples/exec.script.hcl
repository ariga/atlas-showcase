script "exec" "cancel_pending" {
  exec {
    sql = "UPDATE orders SET status = 'canceled' WHERE status = 'pending'"
  }
}
