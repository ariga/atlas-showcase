-- deployment: Creating employee_calculate_overtime...
CREATE PROCEDURE employee_calculate_overtime (IN EmployeeID int, IN OvertimeHours decimal(4,2))
BEGIN
    UPDATE employee_timesheet
    SET HoursWorked = HoursWorked + OvertimeHours
    WHERE EmployeeID = EmployeeID AND WorkDate = CURDATE();
END;
-- deployment: Creating employee_get_department_staff...
CREATE PROCEDURE employee_get_department_staff (IN DepartmentID int)
BEGIN
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.Position,
        e.Salary,
        e.HireDate,
        d.DepartmentName
    FROM employee_staff e
    JOIN employee_department d ON e.DepartmentID = d.DepartmentID
    WHERE e.DepartmentID = DepartmentID AND e.IsActive = TRUE
    ORDER BY e.LastName, e.FirstName;
END;
-- deployment: Creating employee_process_performance_bonus...
CREATE PROCEDURE employee_process_performance_bonus (IN EmployeeID int, IN BonusAmount decimal(8,2))
BEGIN
    DECLARE CurrentSalary DECIMAL(10,2);
DECLARE ReviewRating INT;
SELECT 
        e.Salary, r.Rating
    INTO CurrentSalary, ReviewRating
    FROM employee_staff e
    LEFT JOIN employee_performance_review r ON e.EmployeeID = r.EmployeeID
    WHERE e.EmployeeID = EmployeeID
    ORDER BY r.ReviewDate DESC
    LIMIT 1;
IF ReviewRating >= 4 THEN
        UPDATE employee_staff
        SET Salary = Salary + BonusAmount
        WHERE EmployeeID = EmployeeID;
ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Employee performance rating too low for bonus.';
END IF;
END;
-- deployment: Creating employee_enroll_benefits...
CREATE PROCEDURE employee_enroll_benefits (IN EmployeeID int, IN BenefitID int, IN StartDate date)
BEGIN
    INSERT INTO employee_benefit_enrollment (EmployeeID, BenefitID, StartDate)
    VALUES (EmployeeID, BenefitID, StartDate);
END;
-- deployment: Creating employee_staff.ManagerID...
ALTER TABLE employee_staff ADD COLUMN ManagerID int NULL;
-- deployment: Creating employee_department.LocationID...
ALTER TABLE employee_department ADD COLUMN LocationID int NULL;
