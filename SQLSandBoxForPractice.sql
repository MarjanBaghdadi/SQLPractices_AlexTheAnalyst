--Creating Table 1
Create Table Employee_Demographics 
(EmployeeID int, 
FirstName varchar(50), 
LastName varchar(50), 
Age int, 
Gender varchar(50)
);


--Creating table 2
Create Table Employee_Salary 
(EmployeeID int, 
JobTitle varchar(50), 
Salary int
);


--Table 1 Insert:
Insert into Employee_Demographics VALUES
(1, 'Ali', 'Mira', 43, 'Male'),
(2, 'Pam', 'Anderson', 33, 'Female'),
(3, 'Babak', 'Spielberg', 29, 'Male'),
(4, 'Angela', 'Julie', 37, 'Female'),
(5, 'Toni', 'Anderson', 40, 'Male'),
(6, 'Mady', 'Scott', 35, 'Male'),
(7, 'Mina', 'Asghari', 32, 'Female'),
(8, 'Sina', 'Hamidi', 38, 'Male'),
(9, 'Kaveh', 'Kavi', 34, 'Male');

--Table 2 Insert:
Insert Into Employee_Salary VALUES
(1, 'Salesman', 60000),
(2, 'Receptionist', 34000),
(3, 'Salesman', 63000),
(4, 'Accountant', 55000),
(5, 'HR', 56000),
(6, 'Regional Manager', 67000),
(7, 'Supplier Relations', 45000),
(8, 'Salesman', 56000),
(9, 'Accountant', 51000);


SELECT * FROM Employee_Demographics as dem
JOIN Employee_Salary as sal
ON dem.EmployeeID=sal.EmployeeID;

-----------------------------------------------
--GROUP BY vs PARTITION BY:
-----------------------------------------------

SELECT FirstName, LastName, Gender, Salary, JobTitle,
COUNT(JobTitle) OVER (PARTITION BY JobTitle) as Total_Similar_Job_Titles
FROM Employee_Demographics as dem
JOIN Employee_Salary as sal
	ON dem.EmployeeID=sal.EmployeeID;

SELECT FirstName, LastName, Gender, Salary, JobTitle, COUNT(JobTitle)
FROM Employee_Demographics as dem
JOIN Employee_Salary as sal
ON dem.EmployeeID=sal.EmployeeID
GROUP BY JobTitle, FirstName, LastName, Gender, Salary;

-----------------------------------------------
--CTE(Common Table Expression):
-----------------------------------------------

WITH CTE_Employee as 
(SELECT FirstName, LastName, Gender, Salary, JobTitle,
COUNT(JobTitle) OVER (PARTITION BY JobTitle) as Total_Similar_Job_Titles
FROM Employee_Demographics as dem
JOIN Employee_Salary as sal
	ON dem.EmployeeID=sal.EmployeeID
)
SELECT LastName, JobTitle, Salary FROM CTE_Employee;

-----------------------------------------------
--TEMP Table:
-----------------------------------------------

CREATE TABLE #Employee_temp
(EmployeeID int,
JobTitle varchar(100),
Salary int
)

-- we can insert value like normal table:

INSERT INTO #Employee_temp VALUES ('1', 'HR', '50000');

-- or we can insert all the data from another table and keep it here
-- this is a good trick for bringing huge tables into our current tasks
-- this table stays as long as we are in this session, 
-- we don't have to run it each time like the CTE

INSERT INTO #Employee_temp
SELECT *
FROM Employee_Salary

SELECT * FROM #Employee_temp;

-----------------------------------------------
--DROP TABLE:
-----------------------------------------------
-- Making another TEMP table
-- Trick to use not to face the error for already esisted temp table is "DROP" 

DROP TABLE IF EXISTS #temp_Employee_2
CREATE TABLE #temp_Employee_2
(JobTitle varchar(50),
EmployeePerJob int,
AvgAge int,
AvgSalary int
);

INSERT INTO #temp_Employee_2 
SELECT JobTitle, COUNT(JobTitle), Avg(Age), AVG(salary)
FROM Employee_Demographics as dem
	JOIN Employee_Salary as sal
	ON dem.EmployeeID=sal.EmployeeID
GROUP BY JobTitle;

SELECT * FROM #temp_Employee_2;


-----------------------------------------------
--Create a new table
-----------------------------------------------

CREATE TABLE EmployeeErrors (
EmployeeID varchar(50),
FirstName varchar(50),
LastName varchar(50)
)

INSERT INTO EmployeeErrors VALUES
('  1', 'Marjan', 'Bigy'),
(' 2', 'Maryam', 'Bibi'),
('3 ', 'Reza', 'Bogy')

SELECT * FROM EmployeeErrors

-----------------------------------------------
-- TRIM, LTRIM, RTRIM
-----------------------------------------------

SELECT EmployeeID, TRIM(EmployeeID) AS IDTRIM
FROM EmployeeErrors

SELECT EmployeeID, LTRIM(EmployeeID) AS IDTRIM
FROM EmployeeErrors

SELECT EmployeeID, RTRIM(EmployeeID) AS IDTRIM
FROM EmployeeErrors

-----------------------------------------------
--Using Replace:
-----------------------------------------------

SELECT LastName, REPLACE(LastName, 'Bogy', 'BogBogy') as LastNameFixed
FROM EmployeeErrors

-----------------------------------------------
--Substring:
-----------------------------------------------

SELECT SUBSTRING(FirstName, 1,3) as FirstNameAbbreviated
FROM EmployeeErrors


-----------------------------------------------
--Upper & Lower:
-----------------------------------------------

SELECT LastName, UPPER(FirstName)
FROM EmployeeErrors


--------------------------------------------------
--Stored Procedures:
--------------------------------------------------
-- Group of SQL statements that are created once and stored in the db
-- it accepts input parameters
-- can be used over the network by different users of db
-- and each user can use it on different input data
-- Stored Procedures reduce network traffica nd increase the performance
-- if we modify the stored procedure everyone who will use it in the future will be geting the updates too


--TEST
CREATE PROCEDURE TEST
AS
SELECT * 
FROM Employee_Demographics

EXEC TEST


--ANOTHER STORED PROCEDURE ABIT MORE COMPLEX: 
CREATE PROCEDURE Temp_Employee_Test
AS
CREATE TABLE #temp_employee_test(
JobTitle varchar(100),
EmployeePerJob int,
AvgAge int,
AvgSalary int
)

INSERT INTO #temp_employee_test
SELECT JobTitle, COUNT(JobTitle), AVG(Age), AVG(salary)
FROM Employee_Demographics as dem
JOIN Employee_Salary as sal
	ON dem.EmployeeID = sal.EmployeeID
GROUP BY JobTitle

SELECT * FROM #temp_employee_test

EXEC Temp_Employee_Test @JobTitle = 'Salesman'





-----------------------------------------------
--Subqueries (On SELECT / FROM / WHERE )
-----------------------------------------------

SELECT * 
FROM Employee_Salary

SELECT EmployeeID, Salary, (SELECT AVG(Salary) FROM Employee_Salary) as AVG_Salary_Of_All_Employees
FROM Employee_Salary

--why not group by:
SELECT EmployeeID, Salary, AVG(Salary) as AVG_Salary_Of_All_Employees
FROM Employee_Salary
GROUP BY EmployeeID, Salary
ORDER BY 1,2


SELECT a.EmployeeID, AVG_Salary_Of_All_Employees
FROM (SELECT EmployeeID, Salary, AVG(Salary) OVER () as AVG_Salary_Of_All_Employees
		FROM Employee_Salary) as a


SELECT EmployeeID, Salary, JobTitle
FROM Employee_Salary
WHERE EmployeeID in (
					SELECT EmployeeID 
					FROM Employee_Demographics
					WHERE Age > 30)