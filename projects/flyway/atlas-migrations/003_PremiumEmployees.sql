-- deployment: Creating premium_employees...
CREATE TABLE premium_employees (
    EmployeeID int NOT NULL,
    FirstName varchar(50) NOT NULL,
    LastName varchar(50) NULL,
    PremiumLevel varchar(20) NULL DEFAULT 'Gold',
    JoinDate datetime NULL DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE premium_employees ADD PRIMARY KEY (EmployeeID);
