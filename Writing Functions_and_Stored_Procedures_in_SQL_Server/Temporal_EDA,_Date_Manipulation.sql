-- Temporal EDA, Variables & Date Manipulation!!
-- Learn how to do effective exploratory data analysis on temporal data, create scalar and table variables to store data, and learn how to execute date manipulation. This chapter will also cover the following SQL functions: DATEDIFF( ), DATENAME( ), DATEPART( ), CAST( ), CONVERT( ), GETDATE( ), and DATEADD( ).


-- Transactions per day
-- It's time for you to do some temporal EDA on the BikeShare dataset. Write a query to determine how many transactions exist per day.

-- Sometimes datasets have multiple sources and this query can help you understand if you are missing data.


SELECT
  -- Select the date portion of StartDate
  CONVERT(DATE, StartDate) as StartDate,
  -- Measure how many records exist for each StartDate
  COUNT(StartDate) as CountOfRows 
FROM CapitalBikeShare 
-- Group by the date portion of StartDate
GROUP BY CONVERT(DATE, StartDate)
-- Sort the results by the date portion of StartDate
ORDER BY CONVERT(DATE, StartDate);


-- Seconds or no seconds?
-- In the video, you saw how DATEDIFF() can be used to calculate the trip time by finding the difference between Start and End time, but how do you know the dataset includes seconds in the transactions?

-- Here, you'll use DATEPART() to see how many transactions have seconds greater than zero and how many have them equal to zero. Then you can evaluate if this is an appropriate amount. The CASE statement will segregate the dataset into two categories.


SELECT
	-- Count the number of IDs
	COUNT(ID) AS Count,
    -- Use DATEPART() to evaluate the SECOND part of StartDate
    "StartDate" = CASE WHEN DATEPART(SECOND, StartDate) = 0 THEN 'SECONDS = 0'
					   WHEN DATEPART(SECOND, StartDate) > 0 THEN 'SECONDS > 0' END
FROM CapitalBikeShare
GROUP BY
    -- Use DATEPART() to Group By the CASE statement
	CASE WHEN DATEPART(SECOND, StartDate) = 0 THEN 'SECONDS = 0'
		 WHEN DATEPART(SECOND, StartDate) > 0 THEN 'SECONDS > 0' END



--          Which day of week is busiest?
-- Now that we verified there are seconds consistently in our dataset we can calculate the Total Trip Time for each day of the week.


SELECT
    -- Select the day of week value for StartDate
	DATENAME(WEEKDAY, StartDate) as DayOfWeek,
    -- Calculate TotalTripHours
	SUM(DATEDIFF(second, StartDate, EndDate))/ 3600 as TotalTripHours 
FROM CapitalBikeShare 
-- Group by the day of week
GROUP BY DATENAME(WEEKDAY, StartDate)
-- Order TotalTripHours in descending order
ORDER BY TotalTripHours DESC


-- Find the outliers
-- The previous exercise showed us that Saturday was the busiest day of the month for BikeShare rides. Do you wonder if there were any individual Saturday outliers that contributed to this?


SELECT
	-- Calculate TotalRideHours using SUM() and DATEDIFF()
  	SUM(DATEDIFF(SECOND, StartDate, EndDate))/ 3600 AS TotalRideHours,
    -- Select the DATE portion of StartDate
  	CONVERT(DATE, StartDate) AS DateOnly,
    -- Select the WEEKDAY
  	DATENAME(WEEKDAY, CONVERT(DATE, StartDate)) AS DayOfWeek 
FROM CapitalBikeShare
-- Only include Saturday
WHERE DATENAME(WEEKDAY, StartDate) = 'Saturday' 
GROUP BY CONVERT(DATE, StartDate);



-- DECLARE & CAST
-- Let's use DECLARE() and CAST() to combine a date variable and a time variable into a datetime variable.


-- Create @ShiftStartTime
DECLARE @ShiftStartTime AS time = '08:00 AM'

-- Create @StartDate
DECLARE @StartDate AS date

-- Set StartDate to the first StartDate from CapitalBikeShare
SET 
	@StartDate = (
    	SELECT TOP 1 StartDate 
    	FROM CapitalBikeShare 
    	ORDER BY StartDate ASC
		)

-- Create ShiftStartDateTime
DECLARE @ShiftStartDateTime AS datetime

-- Cast StartDate and ShiftStartTime to datetime data types
SET @ShiftStartDateTime = CAST(@StartDate AS datetime) + CAST(@ShiftStartTime AS datetime) 

SELECT @ShiftStartDateTime


-- DECLARE a TABLE
-- Let's create a TABLE variable to store Shift data and then populate it with static values.


-- Declare @Shifts as a TABLE
DECLARE @Shifts TABLE(
    -- Create StartDateTime column
	StartDateTime datetime,
    -- Create EndDateTime column
	EndDateTime datetime)
-- Populate @Shifts
INSERT INTO @Shifts (StartDateTime, EndDateTime)
	SELECT '3/1/2018 8:00 AM', '3/1/2018 4:00 PM'
SELECT * 
FROM @Shifts


-- INSERT INTO @TABLE
-- Instead of storing static values in a table variable, let's store the result of a query.


-- Declare @RideDates
DECLARE @RideDates TABLE(
    -- Define RideStart column
	RideStart date, 
    -- Define RideEnd column
    RideEnd date)
-- Populate @RideDates
INSERT INTO @RideDates(RideStart, RideEnd)
-- Select the unique date values of StartDate and EndDate
SELECT DISTINCT
    -- Cast StartDate as date
	CAST(StartDate as date),
    -- Cast EndDate as date
	CAST(EndDate as date) 
FROM CapitalBikeShare 
SELECT * 
FROM @RideDates




-- First day of month
-- Here you will use the GETDATE(), DATEDIFF(), and DATEADD() functions to find the first day of the current month.

-- Find the first day of the current month
SELECT DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), '1/1/1900')


