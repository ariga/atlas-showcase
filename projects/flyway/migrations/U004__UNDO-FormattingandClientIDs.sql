-- Generated script

-- deployment: Dropping sales_update_order_status...
DROP PROCEDURE sales_update_order_status;


-- deployment: Creating sales_update_order_status...
CREATE PROCEDURE sales_update_order_status (IN OrderID int, IN NewStatus varchar(20))
BEGIN
    UPDATE sales_orders
    SET Status = NewStatus
    WHERE OrderID = OrderID;
END;


-- deployment: Dropping sales_get_customer_flight_history...
DROP PROCEDURE sales_get_customer_flight_history;


-- deployment: Creating sales_get_customer_flight_history...
CREATE PROCEDURE sales_get_customer_flight_history (IN CustomerID int)
BEGIN
    SELECT 
        o.OrderID,
        f.Airline,
        f.DepartureCity,
        f.ArrivalCity,
        o.OrderDate,
        o.Status,
        o.TotalAmount
    FROM sales_orders o
    JOIN inventory_flight f ON o.FlightID = f.FlightID
    WHERE o.CustomerID = CustomerID
    ORDER BY o.OrderDate;
END;


-- deployment: Dropping sales_apply_discount...
DROP PROCEDURE sales_apply_discount;


-- deployment: Creating sales_apply_discount...
CREATE PROCEDURE sales_apply_discount (IN OrderID int, IN DiscountCode varchar(20))
BEGIN
    DECLARE DiscountID INT;
    DECLARE DiscountPercentage DECIMAL(4, 2);
    DECLARE ExpiryDate DATETIME;

    SELECT 
        DiscountID, DiscountPercentage, ExpiryDate
    INTO DiscountID, DiscountPercentage, ExpiryDate
    FROM sales_discount_code
    WHERE Code = DiscountCode;

    IF DiscountID IS NOT NULL AND ExpiryDate >= CURRENT_TIMESTAMP THEN
        UPDATE sales_orders
        SET TotalAmount = TotalAmount * (1 - DiscountPercentage / 100)
        WHERE OrderID = OrderID;

        INSERT INTO sales_order_audit_log (OrderID, ChangeDescription)
        VALUES (OrderID, CONCAT('Discount ', DiscountCode, ' applied with ', DiscountPercentage, '% off.'));
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid or expired discount code.';
    END IF;
END;


-- deployment: Dropping inventory_update_available_seats...
DROP PROCEDURE inventory_update_available_seats;


-- deployment: Creating inventory_update_available_seats...
CREATE PROCEDURE inventory_update_available_seats (IN FlightID int, IN SeatChange int)
BEGIN
    UPDATE inventory_flight
    SET AvailableSeats = AvailableSeats + SeatChange
    WHERE FlightID = FlightID;
END;


-- deployment: Dropping inventory_add_maintenance_log...
DROP PROCEDURE inventory_add_maintenance_log;


-- deployment: Creating inventory_add_maintenance_log...
CREATE PROCEDURE inventory_add_maintenance_log (IN FlightID int, IN Description varchar(500))
BEGIN
    INSERT INTO inventory_maintenance_log (FlightID, Description, MaintenanceStatus)
    VALUES (FlightID, Description, 'Pending');
END;


-- deployment: Dropping customers_record_feedback...
DROP PROCEDURE customers_record_feedback;


-- deployment: Creating customers_record_feedback...
CREATE PROCEDURE customers_record_feedback (IN CustomerID int, IN Rating int, IN Comments varchar(500))
BEGIN
    INSERT INTO customers_customer_feedback (CustomerID, Rating, Comments)
    VALUES (CustomerID, Rating, Comments);
END;


-- deployment: Dropping customers_customer_feedback.ClientID...
ALTER TABLE customers_customer_feedback DROP COLUMN ClientID;


-- deployment: Dropping customers_customer.ClientID...
ALTER TABLE customers_customer DROP COLUMN ClientID;

