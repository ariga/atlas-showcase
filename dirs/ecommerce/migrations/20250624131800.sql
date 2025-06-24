-- Create trigger "before_order_check"
CREATE TRIGGER `before_order_check` BEFORE INSERT ON `orders` FOR EACH ROW BEGIN
  DECLARE order_total DECIMAL(10, 2);
  SELECT SUM(quantity * price) INTO order_total FROM order_items WHERE order_id = NEW.id;
  IF NEW.total_amount < order_total THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Order total amount must be greater than or equal to the total price of the order items';
  END IF;
END;
