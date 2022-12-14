USE [PortfolioProject]
GO
/****** Object:  StoredProcedure [dbo].[Temp_Employee_Test]    Script Date: 2022-07-31 10:42:37 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[Temp_Employee_Test]
@JobTitle nvarchar(100)
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
WHERE JobTitle = @JobTitle
GROUP BY JobTitle

SELECT * FROM #temp_employee_test