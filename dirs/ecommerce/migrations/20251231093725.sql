-- Create trigger "users_set_updated_at"
CREATE TRIGGER `users_set_updated_at` BEFORE UPDATE ON `users` FOR EACH ROW BEGIN
  SET NEW.updated_at = GREATEST(COALESCE(NEW.updated_at, CURRENT_TIMESTAMP), COALESCE(OLD.updated_at, '1970-01-01 00:00:01'), CURRENT_TIMESTAMP);
END;
