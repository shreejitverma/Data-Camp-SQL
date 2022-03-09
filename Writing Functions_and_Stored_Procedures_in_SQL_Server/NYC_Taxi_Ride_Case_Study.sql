
-- NYC Taxi Ride Case Study!!
-- Apply your new skills in temporal EDA, user-defined functions, and stored procedures to solve a business case problem. Analyze the New York City taxi ride dataset to identify average fare per distance, ride count, and total ride time for each borough on each day of the week. And which pickup locations within the borough should be scheduled for each driver shift?

-- Use EDA to find impossible scenarios
-- Calculate how many YellowTripData records have each type of error discovered during EDA.


SELECT
	-- PickupDate is after today
	COUNT (CASE WHEN PickupDate > GETDATE() THEN 1 END) AS 'FuturePickup',
    -- DropOffDate is after today
	COUNT (CASE WHEN DropOffDate > GETDATE() THEN 1 END) AS 'FutureDropOff',
    -- PickupDate is after DropOffDate
	COUNT (CASE WHEN PickupDate>DropOffDate THEN 1 END) AS 'PickupBeforeDropoff',
    -- TripDistance is 0
	COUNT (CASE WHEN TripDistance = 0 THEN 1 END) AS 'ZeroTripDistance'  
FROM YellowTripData;


-- Mean imputation
-- Create a stored procedure that will apply mean imputation to the YellowTripData records with an incorrect TripDistance of zero. The average trip distance variable should have a precision of 18 and 4 decimal places.


-- Create the stored procedure
CREATE PROCEDURE dbo.cuspImputeTripDistanceMean
AS
BEGIN
-- Specify @AvgTripDistance variable
DECLARE @AvgTripDistance AS numeric (18,4)

-- Calculate the average trip distance
SELECT  @AvgTripDistance = AVG(TripDistance)
FROM YellowTripData
-- Only include trip distances greater than 0
WHERE TripDistance >0

-- Update the records where trip distance is 0
UPDATE YellowTripData
SET  TripDistance =  @AvgTripDistance
WHERE TripDistance = 0
END;



-- Hot Deck imputation
-- Create a function named dbo.GetTripDistanceHotDeck that returns a TripDistance value via Hot Deck methodology. TripDistance should have a precision of 18 and 4 decimal places.


-- Create the function
CREATE FUNCTION dbo.GetTripDistanceHotDeck()
-- Specify return data type
RETURNS numeric(18,4)
AS 
BEGIN
RETURN
	-- Select the first TripDistance value
	(SELECT TOP 1 TripDistance
	FROM YellowTripData
    -- Sample 1000 records
	TABLESAMPLE(1000 rows)
    -- Only include records where TripDistance is > 0
	WHERE TripDistance > 0)
END;


-- CREATE FUNCTIONs
-- Create three functions to help solve the business case:

-- Convert distance from miles to kilometers.
-- Convert currency based on exchange rate parameter.
-- (These two functions should return a numeric value with precision of 18 and 2 decimal places.)
-- Identify the driver shift based on the hour parameter value passed.


-- Create the function
CREATE FUNCTION dbo.ConvertMileToKm (@Miles numeric(18,2))
-- Specify return data type
RETURNS numeric(18,2)
AS
BEGIN
RETURN
	-- Convert Miles to Kilometers
	(SELECT @Miles * 1.609)
END;


-- Test FUNCTIONs
-- Now it's time to test the three functions you wrote in the previous exercise.


SELECT
	-- Select the first 100 records of PickupDate
	TOP 100 PickupDate,
    -- Determine the shift value of PickupDate
	dbo.GetShiftNumber(DATEPART(hour, PickupDate)) AS 'Shift',
    -- Select FareAmount
	FareAmount,
    -- Convert FareAmount to Euro
	dbo.ConvertDollar(FareAmount, 0.87) AS 'FareinEuro',
    -- Select TripDistance
	TripDistance,
    -- Convert TripDistance to kilometers
	dbo.ConvertMiletoKm(TripDistance) AS 'TripDistanceinKM'
FROM YellowTripData




-- Logical weekdays with Hot Deck
-- Calculate Total Fare Amount per Total Distance for each day of week. If the TripDistance is zero use the Hot Deck imputation function you created earlier in the chapter.



SELECT
    -- Select the pickup day of week
	DATENAME(weekday, PickupDate) as DayofWeek,
    -- Calculate TotalAmount per TripDistance
	CAST(AVG(TotalAmount/
            -- Select TripDistance if it's more than 0
			CASE WHEN TripDistance > 0 THEN TripDistance
                 -- Use GetTripDistanceHotDeck()
     			 ELSE dbo.GetTripDistanceHotDeck() END) as decimal(10,2)) as 'AvgFare'
FROM YellowTripData
GROUP BY DATENAME(weekday, PickupDate)
-- Order by the PickupDate day of week
ORDER BY
     CASE 
         WHEN DATENAME(weekday, PickupDate) = 'Monday' THEN 1
         WHEN DATENAME(weekday, PickupDate) = 'Tuesday' THEN 2
         WHEN DATENAME(weekday, PickupDate) = 'Wednesday' THEN 3
         WHEN DATENAME(weekday, PickupDate) = 'Thursday' THEN 4
         WHEN DATENAME(weekday, PickupDate) = 'Friday' THEN 5
         WHEN DATENAME(weekday, PickupDate) = 'Saturday' THEN 6
         WHEN DATENAME(weekday, PickupDate) = 'Sunday' THEN 7
END ASC;


-- Format for Germany
-- Write a query to display the TotalDistance, TotalRideTime and TotalFare for each day and NYC Borough. Display the date, distance, ride time, and fare totals for German culture.

SELECT
    -- Cast PickupDate as a date and display as a German date
	FORMAT(CAST(PickupDate AS date), 'd', 'de-de') AS 'PickupDate',
	Zone.Borough,
    -- Display TotalDistance in the German format
	FORMAT(SUM(TripDistance), 'n', 'de-de') AS 'TotalDistance',
    -- Display TotalRideTime in the German format
	FORMAT(SUM(DATEDIFF(minute, PickupDate, DropoffDate)), 'n', 'de-de') AS 'TotalRideTime',
    -- Display TotalFare in German currency
	FORMAT(SUM(TotalAmount), 'c', 'de-de') AS 'TotalFare'
FROM YellowTripData
INNER JOIN TaxiZoneLookup AS Zone 
ON PULocationID = Zone.LocationID 
GROUP BY
	CAST(PickupDate as date),
    Zone.Borough 
ORDER BY
	CAST(PickupDate as date),
    Zone.Borough;


--     NYC Borough statistics SP
-- It's time to apply what that you have learned in this course and write a stored procedure to solve the first objective of the Taxi Ride business case. Calculate AvgFarePerKM, RideCount and TotalRideMin for each NYC borough and weekday. After discussion with stakeholders, you should omit records where the TripDistance is zero.


CREATE OR ALTER PROCEDURE dbo.cuspBoroughRideStats
AS
BEGIN
SELECT
    -- Calculate the pickup weekday
	DATENAME(weekday, PickupDate) AS 'Weekday',
    -- Select the Borough
	Zone.Borough AS 'PickupBorough',
    -- Display AvgFarePerKM as German currency
	FORMAT(AVG(dbo.ConvertDollar(TotalAmount, .88)/dbo.ConvertMiletoKM(TripDistance)), 'c', 'de-de') AS 'AvgFarePerKM',
    -- Display RideCount in the German format
	FORMAT(COUNT(ID), 'n', 'de-de') AS 'RideCount',
    -- Display TotalRideMin in the German format
	FORMAT(SUM(DATEDIFF(SECOND, PickupDate, DropOffDate))/60, 'n', 'de-de') AS 'TotalRideMin'
FROM YellowTripData
INNER JOIN TaxiZoneLookup AS Zone 
ON PULocationID = Zone.LocationID
-- Only include records where TripDistance is greater than 0
WHERE TripDistance > 0
-- Group by pickup weekday and Borough
GROUP BY DATENAME(WEEKDAY, PickupDate), Zone.Borough
ORDER BY CASE WHEN DATENAME(WEEKDAY, PickupDate) = 'Monday' THEN 1
	     	  WHEN DATENAME(WEEKDAY, PickupDate) = 'Tuesday' THEN 2
              WHEN DATENAME(WEEKDAY, PickupDate) = 'Wednesday' THEN 3
              WHEN DATENAME(WEEKDAY, PickupDate) = 'Thursday' THEN 4
              WHEN DATENAME(WEEKDAY, PickupDate) = 'Friday' THEN 5
              WHEN DATENAME(WEEKDAY, PickupDate) = 'Saturday' THEN 6
              WHEN DATENAME(WEEKDAY, PickupDate) = 'Sunday' THEN 7 END,  
		 SUM(DATEDIFF(SECOND, PickupDate, DropOffDate))/60
DESC
END;



-- NYC Borough statistics results
-- Let's see the results of the dbo.cuspBoroughRideStats stored procedure you just created.

-- Pickup locations by shift
-- It's time to solve the second objective of the business case. What are the AvgFarePerKM, RideCount and TotalRideMin for each pickup location and shift within a NYC Borough?


-- Create the stored procedure
CREATE PROCEDURE dbo.cuspPickupZoneShiftStats
	-- Specify @Borough parameter
	@Borough nvarchar(30)
AS
BEGIN
SELECT
	DATENAME(WEEKDAY, PickupDate) as 'Weekday',
    -- Calculate the shift number
	dbo.GetShiftNumber(DATEPART(hour, PickupDate)) as 'Shift',
	Zone.Zone as 'Zone',
	FORMAT(AVG(dbo.ConvertDollar(TotalAmount, .77)/dbo.ConvertMiletoKM(TripDistance)), 'c', 'de-de') AS 'AvgFarePerKM',
	FORMAT(COUNT (ID),'n', 'de-de') as 'RideCount',
	FORMAT(SUM(DATEDIFF(SECOND, PickupDate, DropOffDate))/60, 'n', 'de-de') as 'TotalRideMin'
FROM YellowTripData
INNER JOIN TaxiZoneLookup as Zone on PULocationID = Zone.LocationID 
WHERE
	dbo.ConvertMiletoKM(TripDistance) > 0 AND
	Zone.Borough = @Borough
GROUP BY
	DATENAME(WEEKDAY, PickupDate),
    -- Group by shift
	dbo.GetShiftNumber(DATEPART(hour, PickupDate)),  
	Zone.Zone
ORDER BY CASE WHEN DATENAME(WEEKDAY, PickupDate) = 'Monday' THEN 1
              WHEN DATENAME(WEEKDAY, PickupDate) = 'Tuesday' THEN 2
              WHEN DATENAME(WEEKDAY, PickupDate) = 'Wednesday' THEN 3
              WHEN DATENAME(WEEKDAY, PickupDate) = 'Thursday' THEN 4
              WHEN DATENAME(WEEKDAY, PickupDate) = 'Friday' THEN 5
              WHEN DATENAME(WEEKDAY, PickupDate) = 'Saturday' THEN 6
              WHEN DATENAME(WEEKDAY, PickupDate) = 'Sunday' THEN 7 END,
         -- Order by shift
         dbo.GetShiftNumber(DATEPART(hour, PickupDate)),
         SUM(DATEDIFF(SECOND, PickupDate, DropOffDate))/60 DESC
END;



-- Pickup locations by shift results
-- Let's see the AvgFarePerKM,RideCount and TotalRideMin for the pickup locations within Manhattan during the different driver shifts of each weekday.


-- Create @Borough
DECLARE @Borough AS nvarchar(30) = 'Manhattan'
-- Execute the SP
EXEC dbo.cuspPickupZoneShiftStats
    -- Pass @Borough
	@Borough = @Borough;

    