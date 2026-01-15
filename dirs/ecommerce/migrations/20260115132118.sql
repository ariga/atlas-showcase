-- Create trigger "users_set_last_login_on_email_verification"
CREATE TRIGGER `users_set_last_login_on_email_verification` BEFORE UPDATE ON `users` FOR EACH ROW FOLLOWS `users_set_updated_at` BEGIN
  IF OLD.email_verified = 0 AND NEW.email_verified = 1 AND NEW.last_login IS NULL THEN
    SET NEW.last_login = CURRENT_TIMESTAMP;
  END IF;
END;
