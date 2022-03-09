-- User Defined Functions!!
-- This chapter will explain how to create, update, and execute user-defined functions (UDFs). You will learn about the various types of UDFs: scalar, inline, and multi-statement table-valued. You’ll also learn best practices.


-- What was yesterday?
-- Create a function that returns yesterday's date.

-- Create GetYesterday()
CREATE FUNCTION GetYesterday()

-- Specify return data type

    RETURNS date 
AS
BEGIN
-- Calculate yesterday's date value
RETURN(SELECT DATEADD(day, -1, GETDATE()))
END 


-- One in one out
-- Create a function named SumRideHrsSingleDay() which returns the total ride time in hours for the @DateParm parameter passed.

-- Create SumRideHrsSingleDay
CREATE FUNCTION SumRideHrsSingleDay (@DateParm date)
-- Specify return data type
RETURNS numeric
AS
-- Begin
BEGIN
RETURN
-- Add the difference between StartDate and EndDate
(SELECT SUM(DATEDIFF(second, StartDate, EndDate))/3600
FROM CapitalBikeShare
 -- Only include transactions where StartDate = @DateParm
WHERE CAST(StartDate AS date) = @DateParm)
-- End
END



-- Multiple inputs one output
-- Often times you will need to pass more than one parameter to a function. Create a function that accepts @StartDateParm and @EndDateParm and returns the total ride hours for all transactions that have a StartDate within the parameter values.


-- Create the function
CREATE FUNCTION SumRideHrsDateRange (@StartDateParm datetime, @EndDateParm datetime)
-- Specify return data type
RETURNS numeric
AS
BEGIN
RETURN
-- Sum the difference between StartDate and EndDate
(SELECT SUM(DATEDIFF(second, StartDate, EndDate))/3600
FROM CapitalBikeShare
-- Include only the relevant transactions
WHERE StartDate > @StartDateParm and StartDate < @EndDateParm)
END



-- Inline TVF
-- Create an inline table value function that returns the number of rides and total ride duration for each StartStation where the StartDate of the ride is equal to the input parameter.


-- Create the function
CREATE FUNCTION SumStationStats(@StartDate AS datetime)
-- Specify return data type
RETURNS TABLE
AS
RETURN
SELECT
	StartStation,
    -- Use COUNT() to select RideCount
	COUNT(ID) AS RideCount,
    -- Use SUM() to calculate TotalDuration
    SUM(DURATION) AS TotalDuration
FROM CapitalBikeShare
WHERE CAST(StartDate as Date) = @StartDate
-- Group by StartStation
GROUP BY StartStation;



-- Multi statement TVF
-- Create a multi statement table value function that returns the trip count and average ride duration for each day for the month & year parameter values passed.


-- Create the function
CREATE FUNCTION CountTripAvgDuration (@Month CHAR(2), @Year CHAR(4))
-- Specify return variable
RETURNS @DailyTripStats TABLE(
	TripDate	date,
	TripCount	int,
	AvgDuration	numeric)
AS
BEGIN
-- Insert query results into @DailyTripStats
INSERT INTO @DailyTripStats
SELECT
    -- Cast StartDate as a date
	CAST(StartDate AS date),
    COUNT(ID),
    AVG(Duration)
FROM CapitalBikeShare
WHERE
	DATEPART(month, StartDate) = @Month AND
    DATEPART(year, StartDate) = @Year
-- Group by StartDate as a date
GROUP BY CAST(StartDate AS date)
-- Return
RETURN
END



-- Execute scalar with select
-- Previously, you created a scalar function named SumRideHrsDateRange(). Execute that function for the '3/1/2018' through '3/10/2018' date range by passing local date variables.

-- Create @BeginDate
DECLARE @BeginDate AS date = '3/1/2018'
-- Create @EndDate
DECLARE @EndDate AS date = '3/10/2018' 
SELECT
  -- Select @BeginDate
  @BeginDate AS BeginDate,
  -- Select @EndDate
  @EndDate AS EndDate,
  -- Execute SumRideHrsDateRange()
  dbo.SumRideHrsDateRange(@BeginDate, @EndDate) AS TotalRideHrs


--   EXEC scalar
-- You created the SumRideHrsSingleDay function earlier in this chapter. Execute that function using the EXEC keyword and store the result in a local variable.

-- Create @RideHrs
DECLARE @RideHrs AS numeric
-- Execute SumRideHrsSingleDay function and store the result in @RideHrs
EXEC @RideHrs = dbo.SumRideHrsSingleDay @DateParm = '3/5/2018' 
SELECT 
  'Total Ride Hours for 3/5/2018:', 
  @RideHrs


--   Execute TVF into variable
-- Remember the table value function you created earlier in this chapter named SumStationStats?. It accepts a datetime parameter and returns the ride count and total ride duration for each starting station where the start date matches the input parameter. Execute SumStationStats now and store the results in a table variable.


-- Create @StationStats
DECLARE @StationStats TABLE(
	StartStation nvarchar(100), 
	RideCount int, 
	TotalDuration numeric)
-- Populate @StationStats with the results of the function
INSERT INTO @StationStats
SELECT TOP 10 *
-- Execute SumStationStats with 3/15/2018
FROM dbo.SumStationStats('3/15/2018') 
ORDER BY RideCount DESC
-- Select all the records from @StationStats
SELECT * 
FROM @StationStats


-- CREATE OR ALTER
-- Change the SumStationStats function to enable SCHEMABINDING. Also change the parameter name to @EndDate and compare to EndDate of CapitalBikeShare table.

-- Update SumStationStats
CREATE OR ALTER FUNCTION dbo.SumStationStats(@EndDate AS date)
-- Enable SCHEMABINDING
RETURNS TABLE WITH SCHEMABINDING
AS
RETURN
SELECT
	StartStation,
    COUNT(ID) AS RideCount,
    SUM(DURATION) AS TotalDuration
FROM dbo.CapitalBikeShare
-- Cast EndDate as date and compare to @EndDate
WHERE CAST(EndDate AS Date) = @EndDate
GROUP BY StartStation;


