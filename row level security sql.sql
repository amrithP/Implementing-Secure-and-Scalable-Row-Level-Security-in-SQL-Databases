-- Step 0: Drop the security policy first if it exists
IF EXISTS (SELECT * FROM sys.security_policies WHERE name = 'SalesPolicy')
    DROP SECURITY POLICY SalesPolicy;
GO

-- Step 1: Drop the table and function if they exist
IF OBJECT_ID('dbo.SalesRecords', 'U') IS NOT NULL
    DROP TABLE dbo.SalesRecords;
GO

IF OBJECT_ID('dbo.fnSecurityPredicate', 'IF') IS NOT NULL
    DROP FUNCTION dbo.fnSecurityPredicate;
GO

-- Step 2: Create a sample table
CREATE TABLE SalesRecords (
    SalesID INT PRIMARY KEY,
    SalesPerson NVARCHAR(50),
    Region NVARCHAR(50),
    Amount DECIMAL(10, 2)
);
GO

-- Insert sample data
INSERT INTO SalesRecords (SalesID, SalesPerson, Region, Amount)
VALUES (1, 'Alice', 'North', 1000.00),
       (2, 'Bob', 'South', 2000.00),
       (3, 'Alice', 'North', 1500.00),
       (4, 'Charlie', 'West', 2500.00);
GO

-- Step 3: Create the security predicate function
CREATE FUNCTION dbo.fnSecurityPredicate(@Region AS NVARCHAR(50))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN 
    SELECT 1 AS fnSecurityPredicateResult
    WHERE @Region = USER_NAME(); -- Assuming region is based on user name
GO

-- Step 4: Create the security policy
CREATE SECURITY POLICY SalesPolicy
ADD FILTER PREDICATE dbo.fnSecurityPredicate(Region)
ON dbo.SalesRecords
WITH (STATE = ON);
GO
