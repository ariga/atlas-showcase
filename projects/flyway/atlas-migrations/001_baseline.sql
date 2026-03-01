-- deployment: Creating employee_department...
CREATE TABLE employee_department (
    DepartmentID int NOT NULL,
    DepartmentName varchar(100) NOT NULL,
    Budget decimal(12,2) NULL,
    ManagerID int NULL,
    CreatedDate datetime NULL DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE employee_department ADD PRIMARY KEY (DepartmentID);
-- deployment: Creating employee_staff...
CREATE TABLE employee_staff (
    EmployeeID int NOT NULL,
    FirstName varchar(50) NOT NULL,
    LastName varchar(50) NOT NULL,
    Email varchar(100) NOT NULL,
    DepartmentID int NULL,
    Position varchar(50) NULL,
    Salary decimal(10,2) NULL,
    HireDate datetime NULL DEFAULT CURRENT_TIMESTAMP,
    IsActive boolean NULL DEFAULT TRUE
);
ALTER TABLE employee_staff ADD PRIMARY KEY (EmployeeID);
-- deployment: Creating employee_timesheet...
CREATE TABLE employee_timesheet (
    TimesheetID int NOT NULL,
    EmployeeID int NULL,
    WorkDate date NULL,
    HoursWorked decimal(4,2) NULL,
    TaskDescription varchar(500) NULL,
    Status varchar(20) NULL DEFAULT 'Pending'
);
ALTER TABLE employee_timesheet ADD PRIMARY KEY (TimesheetID);
-- deployment: Creating employee_performance_review...
CREATE TABLE employee_performance_review (
    ReviewID int NOT NULL,
    EmployeeID int NULL,
    ReviewDate datetime NULL DEFAULT CURRENT_TIMESTAMP,
    Rating int NULL,
    Comments varchar(1000) NULL,
    ReviewerID int NULL
);
ALTER TABLE employee_performance_review ADD PRIMARY KEY (ReviewID);
-- deployment: Creating employee_benefits...
CREATE TABLE employee_benefits (
    BenefitID int NOT NULL,
    BenefitName varchar(100) NOT NULL,
    BenefitType varchar(50) NULL,
    Cost decimal(8,2) NULL,
    Description varchar(500) NULL
);
ALTER TABLE employee_benefits ADD PRIMARY KEY (BenefitID);
-- deployment: Creating employee_benefit_enrollment...
CREATE TABLE employee_benefit_enrollment (
    EnrollmentID int NOT NULL,
    EmployeeID int NULL,
    BenefitID int NULL,
    EnrollmentDate datetime NULL DEFAULT CURRENT_TIMESTAMP,
    StartDate date NULL,
    EndDate date NULL,
    IsActive boolean NULL DEFAULT TRUE
);
ALTER TABLE employee_benefit_enrollment ADD PRIMARY KEY (EnrollmentID);
