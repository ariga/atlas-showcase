-- Generated script


-- deployment: Creating sales_order_audit_log...
CREATE TABLE sales_order_audit_log (
    AuditID int NOT NULL,
    OrderID int NULL,
    ChangeDate datetime NULL DEFAULT CURRENT_TIMESTAMP,
    ChangeDescription varchar(500) NULL
);
ALTER TABLE sales_order_audit_log ADD PRIMARY KEY (AuditID);


-- deployment: Creating sales_orders...
CREATE TABLE sales_orders (
    OrderID int NOT NULL,
    CustomerID int NULL,
    FlightID int NULL,
    OrderDate datetime NULL DEFAULT CURRENT_TIMESTAMP,
    Status varchar(20) NULL DEFAULT 'Pending',
    TotalAmount decimal(10,2) NULL,
    TicketQuantity int NULL
);
ALTER TABLE sales_orders ADD PRIMARY KEY (OrderID);


-- deployment: Creating sales_discount_code...
CREATE TABLE sales_discount_code (
    DiscountID int NOT NULL,
    Code varchar(20) NOT NULL,
    DiscountPercentage decimal(4,2) NULL,
    ExpiryDate datetime NULL
);
ALTER TABLE sales_discount_code ADD PRIMARY KEY (DiscountID);


-- deployment: Creating inventory_maintenance_log...
CREATE TABLE inventory_maintenance_log (
    LogID int NOT NULL,
    FlightID int NULL,
    MaintenanceDate datetime NULL DEFAULT CURRENT_TIMESTAMP,
    Description varchar(500) NULL,
    MaintenanceStatus varchar(20) NULL DEFAULT 'Pending'
);
ALTER TABLE inventory_maintenance_log ADD PRIMARY KEY (LogID);


-- deployment: Creating inventory_flight_route...
CREATE TABLE inventory_flight_route (
    RouteID int NOT NULL,
    DepartureCity varchar(50) NOT NULL,
    ArrivalCity varchar(50) NOT NULL,
    Distance int NOT NULL
);
ALTER TABLE inventory_flight_route ADD PRIMARY KEY (RouteID);


-- deployment: Creating inventory_flight...
CREATE TABLE inventory_flight (
    FlightID int NOT NULL,
    Airline varchar(50) NOT NULL,
    DepartureCity varchar(50) NOT NULL,
    ArrivalCity varchar(50) NOT NULL,
    DepartureTime datetime NOT NULL,
    ArrivalTime datetime NOT NULL,
    Price decimal(10,2) NOT NULL,
    AvailableSeats int NOT NULL
);
ALTER TABLE inventory_flight ADD PRIMARY KEY (FlightID);


-- deployment: Creating inventory_flight_maintenance_status...
CREATE VIEW inventory_flight_maintenance_status AS select `f`.`FlightID` AS `FlightID`,`f`.`Airline` AS `Airline`,`f`.`DepartureCity` AS `DepartureCity`,`f`.`ArrivalCity` AS `ArrivalCity`,count(`m`.`LogID`) AS `MaintenanceCount`,sum((case when (`m`.`MaintenanceStatus` = 'Completed') then 1 else 0 end)) AS `CompletedMaintenance` from (`inventory_flight` `f` left join `inventory_maintenance_log` `m` on((`f`.`FlightID` = `m`.`FlightID`))) group by `f`.`FlightID`,`f`.`Airline`,`f`.`DepartureCity`,`f`.`ArrivalCity`;


-- deployment: Creating customers_loyalty_program...
CREATE TABLE customers_loyalty_program (
    ProgramID int NOT NULL,
    ProgramName varchar(50) NOT NULL,
    PointsMultiplier decimal(3,2) NULL DEFAULT 1.00
);
ALTER TABLE customers_loyalty_program ADD PRIMARY KEY (ProgramID);


-- deployment: Creating customers_customer_feedback...
CREATE TABLE customers_customer_feedback (
    FeedbackID int NOT NULL,
    CustomerID int NULL,
    FeedbackDate datetime NULL DEFAULT CURRENT_TIMESTAMP,
    Rating int NULL,
    Comments varchar(500) NULL
);
ALTER TABLE customers_customer_feedback ADD PRIMARY KEY (FeedbackID);


-- deployment: Creating customers_customer...
CREATE TABLE customers_customer (
    CustomerID int NOT NULL,
    FirstName varchar(50) NOT NULL,
    LastName varchar(50) NOT NULL,
    Email varchar(100) NOT NULL,
    DateOfBirth date NULL,
    Phone varchar(20) NULL,
    Address varchar(200) NULL
);
ALTER TABLE customers_customer ADD PRIMARY KEY (CustomerID);


-- deployment: Creating sales_customer_orders_view...
CREATE VIEW sales_customer_orders_view AS select `c`.`CustomerID` AS `CustomerID`,`c`.`FirstName` AS `FirstName`,`c`.`LastName` AS `LastName`,`o`.`OrderID` AS `OrderID`,`o`.`OrderDate` AS `OrderDate`,`o`.`Status` AS `Status`,`o`.`TotalAmount` AS `TotalAmount` from (`customers_customer` `c` join `sales_orders` `o` on((`c`.`CustomerID` = `o`.`CustomerID`)));


-- deployment: Creating customers_customer_feedback_summary...
CREATE VIEW customers_customer_feedback_summary AS select `c`.`CustomerID` AS `CustomerID`,`c`.`FirstName` AS `FirstName`,`c`.`LastName` AS `LastName`,avg(`f`.`Rating`) AS `AverageRating`,count(`f`.`FeedbackID`) AS `FeedbackCount` from (`customers_customer` `c` left join `customers_customer_feedback` `f` on((`c`.`CustomerID` = `f`.`CustomerID`))) group by `c`.`CustomerID`,`c`.`FirstName`,`c`.`LastName`;


-- deployment: Creating sales_update_order_status...
CREATE PROCEDURE sales_update_order_status (IN OrderID int, IN NewStatus varchar(20))
BEGIN
    UPDATE sales_orders
    SET Status = NewStatus
    WHERE OrderID = OrderID;
END;


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


-- deployment: Creating inventory_update_available_seats...
CREATE PROCEDURE inventory_update_available_seats (IN FlightID int, IN SeatChange int)
BEGIN
    UPDATE inventory_flight
    SET AvailableSeats = AvailableSeats + SeatChange
    WHERE FlightID = FlightID;
END;


-- deployment: Creating inventory_add_maintenance_log...
CREATE PROCEDURE inventory_add_maintenance_log (IN FlightID int, IN Description varchar(500))
BEGIN
    INSERT INTO inventory_maintenance_log (FlightID, Description, MaintenanceStatus)
    VALUES (FlightID, Description, 'Pending');
END;


-- deployment: Creating customers_record_feedback...
CREATE PROCEDURE customers_record_feedback (IN CustomerID int, IN Rating int, IN Comments varchar(500))
BEGIN
    INSERT INTO customers_customer_feedback (CustomerID, Rating, Comments)
    VALUES (CustomerID, Rating, Comments);
END;


-- deployment: Creating sales_order_audit_log.OrderID...
CREATE INDEX OrderID USING BTREE ON sales_order_audit_log(OrderID);


-- deployment: Creating sales_order_audit_log.sales_order_audit_log_ibfk_1...
ALTER TABLE sales_order_audit_log
    ADD CONSTRAINT sales_order_audit_log_ibfk_1 FOREIGN KEY (OrderID)
    REFERENCES sales_orders(OrderID);


-- deployment: Creating sales_orders.FlightID...
CREATE INDEX FlightID USING BTREE ON sales_orders(FlightID);


-- deployment: Creating sales_orders.sales_orders_ibfk_2...
ALTER TABLE sales_orders
    ADD CONSTRAINT sales_orders_ibfk_2 FOREIGN KEY (FlightID)
    REFERENCES inventory_flight(FlightID);


-- deployment: Creating sales_orders.CustomerID...
CREATE INDEX CustomerID USING BTREE ON sales_orders(CustomerID);


-- deployment: Creating sales_orders.sales_orders_ibfk_1...
ALTER TABLE sales_orders
    ADD CONSTRAINT sales_orders_ibfk_1 FOREIGN KEY (CustomerID)
    REFERENCES customers_customer(CustomerID);


-- deployment: Creating sales_discount_code.Code...
CREATE UNIQUE INDEX Code USING BTREE ON sales_discount_code(Code);


-- deployment: Creating inventory_maintenance_log.FlightID...
CREATE INDEX FlightID USING BTREE ON inventory_maintenance_log(FlightID);


-- deployment: Creating inventory_maintenance_log.inventory_maintenance_log_ibfk_1...
ALTER TABLE inventory_maintenance_log
    ADD CONSTRAINT inventory_maintenance_log_ibfk_1 FOREIGN KEY (FlightID)
    REFERENCES inventory_flight(FlightID);


-- deployment: Creating customers_customer_feedback.CustomerID...
CREATE INDEX CustomerID USING BTREE ON customers_customer_feedback(CustomerID);


-- deployment: Creating customers_customer_feedback.customers_customer_feedback_ibfk_1...
ALTER TABLE customers_customer_feedback
    ADD CONSTRAINT customers_customer_feedback_ibfk_1 FOREIGN KEY (CustomerID)
    REFERENCES customers_customer(CustomerID);


-- deployment: Creating customers_customer.Email...
CREATE UNIQUE INDEX Email USING BTREE ON customers_customer(Email);

