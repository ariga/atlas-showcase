CREATE TABLE `current_dept_emp` (`emp_no` int NOT NULL, `dept_no` char(4) NOT NULL, `from_date` date NULL, `to_date` date NULL) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT "VIEW";

CREATE TABLE `dept_emp_latest_date` (`emp_no` int NOT NULL, `from_date` date NULL, `to_date` date NULL) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT "VIEW";

CREATE TABLE `employees` (`emp_no` int NOT NULL, `birth_date` date NOT NULL, `first_name` varchar(14) NOT NULL, `last_name` varchar(16) NOT NULL, `gender` enum('M','F') NOT NULL, `hire_date` date NOT NULL, PRIMARY KEY (`emp_no`)) CHARSET utf8mb4 COLLATE utf8mb4_0900_ai_ci;